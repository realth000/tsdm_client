import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/providers/settings_provider.dart';

part '../generated/providers/net_client_provider.g.dart';

/// Global network http client.
///
/// Now only plan to use directly, no state needed.

@Riverpod(keepAlive: true)
class NetClient extends _$NetClient {
  @override
  Dio build() {
    final settings = ProviderContainer().read(appSettingsProvider);

    dio = Dio()
      ..options = BaseOptions(
        headers: <String, String>{
          'Accept': settings.dioAccept,
          'Accept-Encoding': settings.dioAcceptEncoding,
          'Accept-Language': settings.dioAcceptLanguage,
          'User-Agent': settings.dioUserAgent,
        },
      );

    final cookieJar = CookieJar(
      ignoreExpires: true,
    );

    dio.interceptors.add(CookieManager(cookieJar));

    // TODO: Save cookies.
    // final cookieList = cookieJar.loadForRequest(uri, );

    return dio;
  }

  late final Dio dio;
}
