import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/image_cache.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';

late final Directory _imageCacheDirectory;

/// Init settings, must call before start.
Future<void> initCache() async {
  _imageCacheDirectory =
      Directory('${(await getApplicationCacheDirectory()).path}/images');

  if (!_imageCacheDirectory.existsSync()) {
    await _imageCacheDirectory.create(recursive: true);
  }
}

/// Provider of cached images.
class ImageCacheProvider {
  /// Get the cache info related to [imageUrl].
  DatabaseImageCache? getCacheInfo(String imageUrl) {
    return getIt.get<StorageProvider>().getImageCache(imageUrl);
  }

  /// Get the cache image data related to [imageUrl].
  ///
  /// Only return the image data.
  Future<Uint8List> getCache(String imageUrl) async {
    final cacheInfo = getCacheInfo(imageUrl);
    if (cacheInfo == null) {
      return Future.error('$imageUrl not cached');
    }

    final cacheFile =
        File('${_imageCacheDirectory.path}/${cacheInfo.fileName}');
    if (!cacheFile.existsSync()) {
      return Future.error('$imageUrl cache file not exists');
    }

    return cacheFile.readAsBytes();
  }

  File getCacheFile(String fileName) {
    return File('${_imageCacheDirectory.path}/$fileName');
  }

  /// Update image cached file.
  ///
  /// Update cache file and info in database.
  Future<void> updateCache(String imageUrl, List<int> imageData) async {
    final fileName = imageUrl.fileNameV5();

    // Update image cache info to database.
    await getIt
        .get<StorageProvider>()
        .updateImageCache(imageUrl, fileName: fileName);

    // Make cache.
    final cache = File('${_imageCacheDirectory.path}/$fileName');
    await cache.writeAsBytes(imageData);
  }

  /// Update image last used time.
  ///
  /// Not update the cached file.
  Future<void> updateCacheUsedTime(String imageUrl) async {
    await getIt.get<StorageProvider>().updateImageCacheUsedTime(imageUrl);
  }

  Future<int> calculateCache() async {
    final fileList = _imageCacheDirectory.listSync(recursive: true);
    return fileList.fold<int>(0, (acc, x) {
      return acc + x.statSync().size;
    });
  }

  /// Clear cache in [_imageCacheDirectory].
  Future<void> clearCache() async {
    await getIt.get<StorageProvider>().clearImageCache();
    // FIXME: It is not clear why use this ref first can avoid use after dispose exception.
    // Clear cache in database first, otherwise will get exception when cache size is large enough (50mb):
    //  "Bad state: Tried to use a notifier in an uninitialized state."
    // Currently all cached images are in _imageCacheDirectory, not sub dirs.
    for (final f in _imageCacheDirectory.listSync()) {
      await f.delete(recursive: true);
    }
  }
}
