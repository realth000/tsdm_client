import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/models/database/image_cache.dart';
import 'package:tsdm_client/providers/storage_provider.dart';

part '../generated/providers/image_cache_provider.g.dart';

late final Directory _imageCacheDirectory;

/// Init settings, must call before start.
Future<void> initCache() async {
  _imageCacheDirectory =
      Directory('${(await getApplicationCacheDirectory()).path}/images');

  if (!_imageCacheDirectory.existsSync()) {
    await _imageCacheDirectory.create(recursive: true);
  }
}

@Riverpod(dependencies: [AppStorage])
class ImageCache extends _$ImageCache {
  @override
  Future<void> build() async {}

  /// Get the cache info related to [imageUrl].
  DatabaseImageCache? getCacheInfo(String imageUrl) {
    return ref.read(appStorageProvider).getImageCache(imageUrl);
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

  /// Update image cached file.
  ///
  /// Update cache file and info in database.
  Future<void> updateCache(String imageUrl, List<int> imageData) async {
    final fileName = imageUrl.fileNameV5();

    // Update image cache info to database.
    await ref
        .read(appStorageProvider)
        .updateImageCache(imageUrl, fileName: fileName);

    // Make cache.
    final cache = File('${_imageCacheDirectory.path}/$fileName');
    await cache.writeAsBytes(imageData);
  }

  /// Update image last used time.
  ///
  /// Not update the cached file.
  Future<void> updateCacheUsedTime(String imageUrl) async {
    await ref.read(appStorageProvider).updateImageCacheUsedTime(imageUrl);
  }

  Future<int> calculateCache() async {
    final fileList = _imageCacheDirectory.listSync(recursive: true);
    return fileList.fold<int>(0, (acc, x) {
      return acc + x.statSync().size;
    });
  }

  /// Clear cache in [_imageCacheDirectory].
  Future<void> clearCache() async {
    // Currently all cached images are in _imageCacheDirectory, not sub dirs.
    for (final f in _imageCacheDirectory.listSync()) {
      await f.delete();
    }
  }
}
