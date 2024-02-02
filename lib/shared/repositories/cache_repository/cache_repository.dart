import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';

/// Repository to manage cached files.
class CacheRepository {
  /// Constructor.
  CacheRepository();

  /// Clear all cache.
  Future<void> clearCache() async {
    final imageCacheProvider = getIt.get<ImageCacheProvider>();
    await imageCacheProvider.clearCache();
  }

  /// Calculate cache size.
  Future<int> calculateCache() async {
    final imageCacheProvider = getIt.get<ImageCacheProvider>();
    return imageCacheProvider.calculateCache();
  }

// void dispose() {
//   _controller.close();
// }
}
