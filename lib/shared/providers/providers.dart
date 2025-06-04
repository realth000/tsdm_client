import 'package:system_network_proxy/system_network_proxy.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/cookie_provider/cookie_provider.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_error_saver.dart';
import 'package:tsdm_client/shared/providers/proxy_provider/proxy_provider.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/connection/connection.dart' as conn;
import 'package:tsdm_client/shared/providers/storage_provider/models/database/database.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/platform.dart';

/// Instance names can be used.
abstract final class ServiceKeys {
  /// Net client without cookie.
  static const noCookie = 'normal';

  /// Cookie provider empty user info and cookie.
  static const empty = 'empty';
}

/// 3. All providers **MUST NOT** be directly used by blocs or elsewhere.
///
/// This rule is to ensure clear and lightweight dependencies.
Future<void> initProviders() async {
  if (!isWeb) {
    // Only init cache directories on native platforms.
    await initCache();
  }

  // For `ProxyProvider`.
  // system_network_proxy is only available on desktop platforms.
  if (isDesktop) {
    SystemNetworkProxy.init();
  }

  // TODO: These separated init steps make it not testable.

  /// Dart analyzer does not work on conditional export.
  // ignore: undefined_function
  final db = AppDatabase(conn.connect());
  final preloadedCookie = await preloadCookie(db);
  final preloadedImageCache = await preloadImageCache(db);

  final storageProvider = StorageProvider(db, preloadedCookie, preloadedImageCache);

  final settingsRepo = SettingsRepository(storageProvider);
  await settingsRepo.init();

  getIt
    ..registerSingleton(ProxyProvider())
    ..registerSingleton(db)
    ..registerSingleton(storageProvider)
    ..registerSingleton(settingsRepo)
    ..registerSingleton(CookieProvider.build())
    ..registerFactory(CookieProvider.buildEmpty, instanceName: ServiceKeys.empty)
    ..registerSingleton(ImageCacheProvider.new)
    ..registerFactory(NetClientProvider.build)
    ..registerFactory(NetClientProvider.buildNoCookie, instanceName: ServiceKeys.noCookie)
    ..registerSingleton(NetErrorSaver());
  await getIt.allReady();

  getIt.registerSingleton(ImageCacheProvider(getIt.get<NetClientProvider>(instanceName: ServiceKeys.noCookie)));
  await getIt.allReady();
}
