import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/providers/settings_provider.dart';

part '../generated/providers/net_client_provider.g.dart';

bool _initialized = false;
late final FileStorage _cookieStorage;

Future<void> initCookieStorage() async {
  if (_initialized) {
    return;
  }

  final cookiePath = await getApplicationSupportDirectory();
  _cookieStorage = FileStorage(cookiePath.path);

  _initialized = true;
}

/// Global network http client.
///
/// Now only plan to use directly, no state needed.
@Riverpod(keepAlive: true, dependencies: [AppSettings])
class NetClient extends _$NetClient {
  @override
  Dio build() {
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
      storage: _cookieStorage,
    );

    dio.interceptors.add(CookieManager(cookieJar));

    return dio;
  }

  late final Dio dio;
}
