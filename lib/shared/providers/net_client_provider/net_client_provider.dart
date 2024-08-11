import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/cookie_provider/cookie_provider.dart';
import 'package:tsdm_client/shared/providers/cookie_provider/models/cookie_data.dart';
import 'package:tsdm_client/utils/logger.dart';

extension _WithFormExt<T> on Dio {
  Future<Response<T>> postWithForm(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
    );
  }
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
  factory NetClientProvider.build({
    Dio? dio,
    UserLoginInfo? userLoginInfo,
    bool startLogin = false,
    bool logout = false,
  }) {
    talker.debug('build cookie with user info: $userLoginInfo');
    final d = dio ?? getIt.get<SettingsRepository>().buildDefaultDio();
    final cookie = getIt.get<CookieProvider>().build(
          userLoginInfo: userLoginInfo,
          startLogin: startLogin,
          logout: logout,
        );
    final cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: cookie,
    );
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
        return client;
      },
    );
    d.interceptors
      ..add(CookieManager(cookieJar))
      ..add(_ErrorHandler());

    return NetClientProvider._(d);
  }

  /// Build a [NetClientProvider] instance that does NOT load cookie.
  factory NetClientProvider.buildNoCookie({Dio? dio}) {
    final d = dio ?? getIt.get<SettingsRepository>().buildDefaultDio();
    d.interceptors.add(_ErrorHandler());
    return NetClientProvider._(d);
  }

  final Dio _dio;

  /// Make a GET request to [path].
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final resp =
        // FIXME: Handle DioException.
        await _dio.get<dynamic>(path, queryParameters: queryParameters);
    return resp;
  }

  /// Make a GET request to the given [uri].
  Future<Response<dynamic>> getUri(Uri uri) async {
    // FIXME: Handle DioException.
    final resp = await _dio.getUri<dynamic>(uri);
    return resp;
  }

  /// Make a GET request to [path], with options set to image types.
  Future<Response<dynamic>> getImage(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    // FIXME: Handle DioException.
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
      return Future.error('resp code=${resp.statusCode}');
    }
    return resp;
  }

  /// Get a image from the given [uri].
  Future<Response<dynamic>> getImageFromUri(Uri uri) async {
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
      return Future.error('resp code=${resp.statusCode}');
    }
    return resp;
  }

  /// Post [data] to [path] with [queryParameters].
  ///
  /// When post a form data, use [postForm] instead.
  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final resp =
        _dio.post<dynamic>(path, data: data, queryParameters: queryParameters);
    return resp;
  }

  /// Post a form [data] to url [path] with [queryParameters].
  ///
  /// Automatically set `Content-Type` to `application/x-www-form-urlencoded`.
  Future<Response<dynamic>> postForm(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final resp =
        _dio.postWithForm(path, data: data, queryParameters: queryParameters);
    return resp;
  }

  /// Post a form [data] to url [path] in `Content-Type` multipart/form-data.
  ///
  /// Automatically set `Content-Type` to `multipart/form-data`.
  Future<Response<dynamic>> postMultipartForm(
    String path, {
    required Map<String, String> data,
  }) async {
    final resp = _dio.post<dynamic>(
      path,
      options: Options(
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: Headers.multipartFormDataContentType,
        },
        validateStatus: (code) {
          if (code == 301 || code == 200) {
            return true;
          }
          return false;
        },
      ),
      data: FormData.fromMap(data),
    );
    return resp;
  }

  /// Download the file from url [path] and save to [savePath].
  Future<void> download(
    String path,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) async {
    await _dio.download(
      path,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      data: data,
      options: options,
    );
  }
}

/// Handle exceptions during web request.
class _ErrorHandler extends Interceptor with LoggerMixin {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    error('${err.type}: ${err.error},${err.message}');

    if (err.type == DioExceptionType.badResponse) {
      // Till now we can do nothing if encounter a bad response.
    }

    if (err.type == DioExceptionType.unknown &&
        err.error.runtimeType == HandshakeException) {
      // Likely we have an error in SSL handshake.
      handler.resolve(Response(requestOptions: RequestOptions()));
      return;
    }

    // Do not block error handling.
    handler.next(err);
  }
}
