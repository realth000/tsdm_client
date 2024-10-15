import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_brotli_transformer/dio_brotli_transformer.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/cookie_provider/cookie_provider.dart';
import 'package:tsdm_client/shared/providers/cookie_provider/models/cookie_data.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_error_saver.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/platform.dart';

/// Map exception to [AppException].
AppException mapException(Object error, StackTrace st) {
  if (error case DioException(:final response)) {
    return HttpHandshakeFailedException(
      error.message ?? '<unknown error>',
      statusCode: response?.statusCode,
      headers: response?.headers,
    );
  }
  return HttpRequestFailedException(null);
}

extension _WithFormExt<T> on Dio {
  AsyncEither<Response<T>> postWithForm(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) =>
      AsyncEither.tryCatch(
        () async => post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          ),
        ),
        mapException,
      );
}

/// A http client to do web request.
///
/// With optional [CookieData] use in requests.
///
/// Also a wrapper of [Dio] instance.
///
/// Instance should be unique when making requests.
final class NetClientProvider with LoggerMixin {
  /// Constructor.
  NetClientProvider._(Dio dio) : _dio = dio;

  /// Build a [NetClientProvider] instance.
  ///
  /// ## Parameters
  ///
  /// * Set [forceDesktop] to false when desire server response with a mobile
  ///   layout page.
  factory NetClientProvider.build({
    Dio? dio,
    UserLoginInfo? userLoginInfo,
    bool startLogin = false,
    bool logout = false,
    bool forceDesktop = true,
  }) {
    final d = dio ?? getIt.get<SettingsRepository>().buildDefaultDio();
    if (!isWeb) {
      talker.debug('build cookie with user info: $userLoginInfo');
      final cookie = getIt.get<CookieProvider>().build(
            userLoginInfo: userLoginInfo,
            startLogin: startLogin,
            logout: logout,
          );
      final cookieJar = PersistCookieJar(
        ignoreExpires: true,
        storage: cookie,
      );
      d.interceptors.add(CookieManager(cookieJar));
      if (forceDesktop) {
        d.interceptors.add(_ForceDesktopLayoutInterceptor());
      }

      // Handle "CERTIFICATE_VERIFY_FAILED: unable to get local issuer
      // certificate" error.
      // ref: https://stackoverflow.com/a/77005574
      d.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          // Don't trust any certificate just because their root cert is
          // trusted.
          final client = HttpClient(context: SecurityContext())
            ..badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;

          final settings = getIt.get<SettingsRepository>().currentSettings;
          final useProxy = settings.netClientUseProxy;
          final proxy = settings.netClientProxy;
          if (useProxy && proxy.isNotEmpty) {
            client.findProxy = (uri) => 'PROXY $proxy';
          }

          return client;
        },
      );
      d.interceptors.add(_ErrorHandler());
      // decode br content-type.
      d.transformer = DioBrotliTransformer();
    }

    return NetClientProvider._(d);
  }

  /// Build a [NetClientProvider] instance that does NOT load cookie.
  factory NetClientProvider.buildNoCookie({Dio? dio}) {
    final d = dio ?? getIt.get<SettingsRepository>().buildDefaultDio();
    d.interceptors.add(_ErrorHandler());
    // decode br content-type.
    d.transformer = DioBrotliTransformer();
    return NetClientProvider._(d);
  }

  final Dio _dio;

  /// Make a GET request to [path].
  AsyncEither<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      AsyncEither.tryCatch(
        () async => _dio.get<dynamic>(path, queryParameters: queryParameters),
        mapException,
      );

  /// Make a GET request to the given [uri].
  AsyncEither<Response<dynamic>> getUri(Uri uri) => AsyncEither.tryCatch(
        () async => _dio.getUri<dynamic>(uri),
        mapException,
      );

  /// Make a GET request to [path], with options set to image types.
  AsyncEither<Response<dynamic>> getImage(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      AsyncEither.tryCatch(
        () async {
          final resp = await _dio.get<dynamic>(
            path,
            queryParameters: queryParameters,
            options: Options(
              responseType: ResponseType.bytes,
              headers: {
                HttpHeaders.acceptHeader: 'image/avif,image/webp,*/*;q=0.8',
                HttpHeaders.acceptEncodingHeader: 'gzip, deflate, br',
              },
            ),
          );

          if (resp.statusCode != HttpStatus.ok) {
            throw HttpRequestFailedException(resp.statusCode);
          }
          return resp;
        },
        mapException,
      );

  /// Get a image from the given [uri].
  AsyncEither<Response<dynamic>> getImageFromUri(Uri uri) =>
      AsyncEither.tryCatch(
        () async {
          final resp = await _dio.getUri<dynamic>(
            uri,
            options: Options(
              responseType: ResponseType.bytes,
              headers: {
                HttpHeaders.acceptHeader: 'image/avif,image/webp,*/*;q=0.8',
                HttpHeaders.acceptEncodingHeader: 'gzip, deflate, br',
              },
            ),
          );

          if (resp.statusCode != HttpStatus.ok) {
            throw HttpRequestFailedException(resp.statusCode);
          }
          return resp;
        },
        mapException,
      );

  /// Post [data] to [path] with [queryParameters].
  ///
  /// When post a form data, use [postForm] instead.
  AsyncEither<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) =>
      AsyncEither.tryCatch(
        () async => _dio.post<dynamic>(
          path,
          data: data,
          queryParameters: queryParameters,
        ),
        mapException,
      );

  /// Post a form [data] to url [path] with [queryParameters].
  ///
  /// Automatically set `Content-Type` to `application/x-www-form-urlencoded`.
  AsyncEither<Response<dynamic>> postForm(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.postWithForm(path, data: data, queryParameters: queryParameters);

  /// Post a form [data] to url [path] in `Content-Type` multipart/form-data.
  ///
  /// Automatically set `Content-Type` to `multipart/form-data`.
  AsyncEither<Response<dynamic>> postMultipartForm(
    String path, {
    required Map<String, String> data,
  }) =>
      AsyncEither.tryCatch(
        () async => _dio.post<dynamic>(
          path,
          options: Options(
            headers: <String, String>{
              HttpHeaders.contentTypeHeader:
                  Headers.multipartFormDataContentType,
            },
            validateStatus: (code) {
              if (code == 301 || code == 200) {
                return true;
              }
              return false;
            },
          ),
          data: FormData.fromMap(data),
        ),
        mapException,
      );

  /// Download the file from url [path] and save to [savePath].
  AsyncVoidEither download(
    String path,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) =>
      AsyncVoidEither.tryCatch(
        () async => _dio.download(
          path,
          savePath,
          onReceiveProgress: onReceiveProgress,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          deleteOnError: deleteOnError,
          lengthHeader: lengthHeader,
          data: data,
          options: options,
        ),
        mapException,
      );
}

/// Handle exceptions during web request.
class _ErrorHandler extends Interceptor with LoggerMixin {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    getIt.get<NetErrorSaver>().clear();
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    error('${err.requestOptions} ${err.type}: ${err.error},${err.message}');
    getIt.get<NetErrorSaver>().save(err.message);

    if (err.type == DioExceptionType.badResponse) {
      // Till now we can do nothing if encounter a bad response.
    }

    if (err.type == DioExceptionType.unknown &&
        err.error.runtimeType == HandshakeException) {
      // Likely we have an error in SSL handshake.
    }

    // Do not block error handling.
    handler.next(err);
  }
}

/// Force request url with desktop, only for server site.
///
/// Works by append query parameter "mobile=no".
///
/// Only use this class when sending request to forum server.
class _ForceDesktopLayoutInterceptor extends Interceptor with LoggerMixin {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters['mobile'] = 'no';
    handler.next(options);
  }
}
