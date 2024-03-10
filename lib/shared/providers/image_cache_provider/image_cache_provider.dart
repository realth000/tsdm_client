import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/image_cache.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';

/// Directory to save common image cache.
late final Directory _imageCacheDirectory;

/// Directory to save emoji image cache used in bbcode editor.
///
/// Actually emoji should be managed under cache too. But we decide to put in
/// another directory to keep the state of emoji longer than regular image
/// cache, and of course, clear emoji cache outside regular cache.
///
/// Also, more kinds of image cache is planned to launch in future:
/// * User avatar.
/// * Forum cover.
///
/// When cleaning cache, it is a good choice to show the different cache kinds
/// to let user to decide what to delete like the browser does. This is in plan.
///
/// Emoji on TSDM is separated into different groups and have an id:
///
/// Group      Name
/// "钟梦篱" -> {:16_894:}
///
/// When saving emoji, name the image file with name "${GROUP_ID}_${ID}.jpg"
///
/// All available emojis are parsed from a static cached JS script called
/// common_smilies_var.js
/// https://tsdm39.com/data/cache/common_smilies_var.js?y1Z
late final Directory _emojiCacheDirectory;

/// Init settings, must call before start.
Future<void> initCache() async {
  _imageCacheDirectory =
      Directory('${(await getApplicationCacheDirectory()).path}/images');
  _emojiCacheDirectory =
      Directory('${(await getApplicationCacheDirectory()).path}/emoji');

  if (!_imageCacheDirectory.existsSync()) {
    await _imageCacheDirectory.create(recursive: true);
  }
  if (!_emojiCacheDirectory.existsSync()) {
    await _emojiCacheDirectory.create(recursive: true);
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

  /// Get the cached file with [fileName] synchronously.
  ///
  /// **WARNING**: Make sure the [fileName] exists and safe to read before
  /// calling this function.
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

  /// Calculate cache size in bytes.
  Future<int> calculateCache() async {
    final fileList = _imageCacheDirectory.listSync(recursive: true);
    return fileList.fold<int>(0, (acc, x) {
      return acc + x.statSync().size;
    });
  }

  /// Clear cache in [_imageCacheDirectory].
  Future<void> clearCache() async {
    await getIt.get<StorageProvider>().clearImageCache();
    // FIXME: It is not clear why use this ref first can avoid use after
    //  dispose exception.
    // Clear cache in database first, otherwise will get exception when cache
    // size is large enough (50mb):
    //  "Bad state: Tried to use a notifier in an uninitialized state."
    // Currently all cached images are in _imageCacheDirectory, not sub dirs.
    for (final f in _imageCacheDirectory.listSync()) {
      await f.delete(recursive: true);
    }
  }

  ///////////////////////// Emoji Cache /////////////////////////

  /// Emoji cache is save as jpg file no matter the real content.
  String _formatEmojiCachePath(String groupId, String id) =>
      '${_emojiCacheDirectory.path}/${groupId}_$id.jpg';

  /// Get the cached file of emoji with specified [groupId] and [id].
  Future<Uint8List> getEmojiCache(String groupId, String id) async {
    final cacheFile = File(_formatEmojiCachePath(groupId, id));
    if (!cacheFile.existsSync()) {
      return Future.error('$cacheFile cache file not exists');
    }
    return cacheFile.readAsBytes();
  }

  /// Clear all emoji cache files.
  Future<void> clearEmojiCache() async {
    for (final f in _emojiCacheDirectory.listSync()) {
      await f.delete(recursive: true);
    }
  }

  /// Update emoji cache.
  Future<void> updateEmojiCache(
    String groupId,
    String id,
    List<int> imageData,
  ) async {
    final fileName = _formatEmojiCachePath(groupId, id);
    // Make cache.
    final cache = File(fileName);
    await cache.writeAsBytes(imageData);
  }
}
