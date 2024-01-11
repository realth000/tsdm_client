import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';

//enum CacheRepoStatus {
//  /// Waiting for action.
//  waiting,
//
//  /// Calculating cache.
//  calculating,
//
//  /// Clearing cache.
//  clearing,
//}

/// Repository to manage cached files.
class CacheRepository {
  CacheRepository() {
    // _controller.add(CacheRepoStatus.waiting);
  }

  // final _controller = BehaviorSubject<CacheRepoStatus>();

  // Stream<CacheRepoStatus> get status => _controller.asBroadcastStream();

  Future<void> clearCache() async {
    final imageCacheProvider = getIt.get<ImageCacheProvider>();
    await imageCacheProvider.clearCache();
  }

  Future<int> calculateCache() async {
    final imageCacheProvider = getIt.get<ImageCacheProvider>();
    return imageCacheProvider.calculateCache();
  }

// void dispose() {
//   _controller.close();
// }
}
