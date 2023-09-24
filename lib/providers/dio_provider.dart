import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/settings_provider.dart';

/// Provider of dio.
///
/// Now only plan to use directly, no state needed.
final dioProvider = Provider<Dio>((ref) => _initDio());

Dio _initDio() {
  final settings = ProviderContainer().read(settingsProvider);

  final dio = Dio()
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
