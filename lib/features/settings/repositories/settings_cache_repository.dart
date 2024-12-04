import 'package:tsdm_client/features/settings/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';

/// Repository to manage cached files.
class SettingsCacheRepository {
  /// Constructor.
  const SettingsCacheRepository();

  /// Clear all cache.
  Future<void> clearCache(CacheClearInfo clearInfo) async {
    final imageCacheProvider = getIt.get<ImageCacheProvider>();
    await imageCacheProvider.clearCache(clearInfo);
    await getIt.get<StorageProvider>().clearUserAvatarInfo();
  }

  /// Calculate cache size.
  Future<CacheStorageInfo> calculateCache() async {
    final imageCacheProvider = getIt.get<ImageCacheProvider>();
    return imageCacheProvider.calculateCache();
  }

// void dispose() {
//   _controller.close();
// }
}
