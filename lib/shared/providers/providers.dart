import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/checkin_provider.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/checkin_provider_impl.dart';
import 'package:tsdm_client/shared/providers/cookie_provider/cookie_provider.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_error_saver.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/database.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/platform.dart';

/// Instance names can be used.
abstract final class ServiceKeys {
  /// Net client without cookie.
  static const noCookie = 'normal';
}

/// 3. All providers **MUST NOT** be directly used by blocs or elsewhere.
///
/// This rule is to ensure clear and lightweight dependencies.
Future<void> initProviders() async {
  if (!isWeb) {
    // Only init cache directories on native platforms.
    await initCache();
  }

  // TODO: These separated init steps make it not testable.

  final db = AppDatabase();
  final preloadedCookie = await preloadCookie(db);
  final preloadedImageCache = await preloadImageCache(db);

  final storageProvider =
      StorageProvider(db, preloadedCookie, preloadedImageCache);

  final settingsRepo = SettingsRepository(storageProvider);
  await settingsRepo.init();

  getIt
    ..registerSingleton(db)
    ..registerSingleton(storageProvider)
    ..registerFactory(CookieProvider.new)
    ..registerSingleton(settingsRepo)
    ..registerSingleton(ImageCacheProvider.new)
    ..registerFactory(NetClientProvider.build)
    ..registerFactory(
      NetClientProvider.buildNoCookie,
      instanceName: ServiceKeys.noCookie,
    )
    ..registerFactory<CheckinProvider>(CheckInProviderImpl.new)
    ..registerFactory(ImageCacheProvider.new)
    ..registerSingleton(NetErrorSaver());
  await getIt.allReady();
}
