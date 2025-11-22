import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:tsdm_client/instance.dart';

/// The method channel for [KotlinHttpClient].
abstract class _AndroidHttpMethodChannel {
  static const _httpChannel = MethodChannel('kzs.th000.tsdm_client/httpChannel');

  static const _methodGet = 'get';
  static const _methodPost = 'postForm';
  static const _methodPostMultipart = 'postMultipart';

  /// Make a GET request.
  static Future<_KotlinHttpResponse?> _get({required String url, required Map<String, String> headers}) async {
    try {
      final resp = await _httpChannel.invokeMethod<Map<Object?, Object?>>(_methodGet, {'url': url, 'headers': headers});
      if (resp == null) {
        return null;
      }
      return _KotlinHttpResponse._fromRawResp(resp);
    } on PlatformException catch (e, st) {
      talker.handle(e, st, '[KtHttp] GET failed on $url');
      return null;
    }
  }

  /// Post form data.
  static Future<_KotlinHttpResponse?> _postForm({
    required String url,
    required Map<String, String> headers,
    required Map<String, String> body,
  }) async {
    try {
      final resp = await _httpChannel.invokeMethod<Map<Object?, Object?>>(_methodPost, {
        'url': url,
        'headers': headers,
        'body': body,
      });
      if (resp == null) {
        return null;
      }
      return _KotlinHttpResponse._fromRawResp(resp);
    } on PlatformException catch (e, st) {
      talker.handle(e, st, '[KtHttp] POST form failed on $url');
      return null;
    }
  }

  /// Post multipart data.
  static Future<_KotlinHttpResponse?> _postMultipart({
    required String url,
    required Map<String, String> headers,
    required Map<String, String> body,
  }) async {
    try {
      final resp = await _httpChannel.invokeMethod<Map<Object?, Object?>>(_methodPostMultipart, {
        'url': url,
        'headers': headers,
        'body': body,
      });
      if (resp == null) {
        return null;
      }
      return _KotlinHttpResponse._fromRawResp(resp);
    } on PlatformException catch (e, st) {
      talker.handle(e, st, '[KtHttp] POST multipart failed on $url');
      return null;
    }
  }
}

/// The http response.
///
/// Note that the response is not derived from `Response` or `BaseResponse` from `dart:http` package,
/// because we want to keep the header with multiple values as `Map<String, List<String>>` instead of
/// `Map<String, String>`.
final class _KotlinHttpResponse {
  const _KotlinHttpResponse._({
    required this.statusCode,
    required this.headers,
    required this.body,
    required this.isRedirect,
  });

  factory _KotlinHttpResponse._fromRawResp(Map<Object?, Object?> resp) => _KotlinHttpResponse._(
    statusCode: resp['statusCode']! as int,
    // headers: Map.castFrom(resp['headers']! as Map<Object?, Object?>),
    headers: _collectHeaders(resp['headers']! as Map<Object?, Object?>),
    body: resp['body']! as Uint8List,
    isRedirect: resp['isRedirect']! as bool,
  );

  final int statusCode;
  final Map<String, List<String>> headers;
  final Uint8List body;
  final bool isRedirect;

  static Map<String, List<String>> _collectHeaders(Map<Object?, Object?> headers) {
    final ret = <String, List<String>>{};
    for (final entry in headers.entries) {
      ret[entry.key! as String] = (entry.value! as List<Object?>).whereType<String>().toList();
    }

    return ret;
  }
}

/// The Http client implemented with Kotlin and OkHttp.
///
/// This http client is only available on Android platform, to solve the following issues:
///
/// 1. `dart:http` can not perform requests when app goes to background. It has been reported to the GitHub issue
///   tracker but no fix or workaround available.
/// 2. `dart:http` is slow on Android, compared to Kotlin ones and `cronet_http` package.
/// 3. The `cronet_http` package is not configurable and has issue on proxy detection.
///
/// Use kotlin native http client to overcome these issues.
///
/// Note that this class is not derived form `dart:http:BaseClient`, unlike `cronet_http`, because we want to keep
/// multiple header structure as `Map<String, List<String>>` instead of `Map<String, String>`.
final class KotlinHttpClient {
  Future<_KotlinHttpResponse> _get(Uri url, {Map<String, String>? headers}) async {
    if (!Platform.isAndroid) {
      throw http.ClientException('Only available on Android');
    }
    final rawResp = await _AndroidHttpMethodChannel._get(url: url.toString(), headers: headers ?? {});
    if (rawResp == null) {
      throw http.ClientException('null raw response');
    }
    return rawResp;
  }

  Future<_KotlinHttpResponse> _post(Uri url, {Map<String, String>? headers, Object? body}) async {
    if (!Platform.isAndroid) {
      throw http.ClientException('Only available on Android');
    }

    if (body == null) {
      throw http.ClientException('post body is null');
    }

    final rawResp = switch (headers?[HttpHeaders.contentTypeHeader]?.split(';').firstOrNull ?? '') {
      'application/x-www-form-urlencoded' => await _AndroidHttpMethodChannel._postForm(
        url: url.toString(),
        headers: headers ?? {},
        body: body as Map<String, String>,
      ),
      'multipart/form-data' => await _AndroidHttpMethodChannel._postMultipart(
        url: url.toString(),
        headers: headers ?? {},
        body: body as Map<String, String>,
      ),
      final v => throw UnsupportedError('unsupported content type: $v'),
    };
    if (rawResp == null) {
      throw http.ClientException('null raw response');
    }
    return rawResp;
  }
}

/// The adaptor for [KotlinHttpClient] to run together with `dio`.
class KotlinHttpClientAdapter implements HttpClientAdapter {
  /// Constructor.
  const KotlinHttpClientAdapter(this._client);

  final KotlinHttpClient _client;

  @override
  void close({bool force = false}) {
    // Do nothing.
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // Remove accept encoding header to let kotlin side handle it.
    final resp = await switch (options.method) {
      'GET' => _client._get(
        options.uri,
        headers: Map.from(options.headers.filter((v) => v is String))
          ..removeWhere((k, v) => k.toLowerCase() == HttpHeaders.acceptEncodingHeader),
      ),
      'POST' => _client._post(
        options.uri,
        headers: Map.from(options.headers.filter((v) => v is String))
          ..removeWhere((k, v) => k.toLowerCase() == HttpHeaders.acceptEncodingHeader),
        body: options.data,
      ),
      final v => throw UnsupportedError('unsupported http method $v'),
    };

    return ResponseBody.fromBytes(
      resp.body,
      resp.statusCode,
      isRedirect: resp.isRedirect,
      headers: Map.castFrom(resp.headers),
    );
  }
}
