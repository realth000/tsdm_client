import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/providers/cookie_provider.dart';
import 'package:tsdm_client/providers/settings_provider.dart';

part '../generated/providers/net_client_provider.g.dart';

/// Global network http client.
///
/// Now only plan to use directly, no state needed.
@Riverpod(dependencies: [AppSettings, Cookie])
class NetClient extends _$NetClient {
  @override
  Dio build({String? username}) {
    final settings = ref.read(appSettingsProvider);

    dio = Dio()
      ..options = BaseOptions(
        headers: <String, String>{
          'Accept': settings.dioAccept,
          'Accept-Encoding': settings.dioAcceptEncoding,
          'Accept-Language': settings.dioAcceptLanguage,
          'User-Agent': settings.dioUserAgent,
        },
      );

    final cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: ref.read(cookieProvider(username: username)),
    );

    dio.interceptors.add(CookieManager(cookieJar));

    return dio;
  }

  late final Dio dio;
}
