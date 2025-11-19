import 'package:tsdm_client/features/settings/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

/// Repository to manage cached files.
class SettingsCacheRepository {
  /// Constructor.
  const SettingsCacheRepository();

  /// Clear all cache.
  Future<void> clearCache(CacheClearInfo clearInfo) async {
    final imageCacheProvider = getIt.get<ImageCacheProvider>();
    await imageCacheProvider.clearCache(clearInfo);
    await closeLogSink();
    if (clearInfo.clearLog) {
      final logDir = await getLogDir();
      if (logDir.existsSync()) {
        for (final entity in logDir.listSync()) {
          await entity.delete(recursive: true);
        }
      }
    }
    await openLogSink();
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
