import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/settings/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/database.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

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

/// Info json file contains all emoji group info.
late final File _emojiCacheInfoFile;

/// Init settings, must call before start.
Future<void> initCache() async {
  _imageCacheDirectory =
      Directory('${(await getApplicationCacheDirectory()).path}/images');
  _emojiCacheDirectory =
      Directory('${(await getApplicationSupportDirectory()).path}/emoji');
  _emojiCacheInfoFile = File('${_emojiCacheDirectory.path}/emoji.json');

  if (!_imageCacheDirectory.existsSync()) {
    await _imageCacheDirectory.create(recursive: true);
  }
  if (!_emojiCacheDirectory.existsSync()) {
    await _emojiCacheDirectory.create(recursive: true);
  }
}

/// Provider of cached images.
final class ImageCacheProvider with LoggerMixin {
  /// Regexp that matches emoji bbcode.
  ///
  /// {:10_200:} format.
  static final _emojiCodeRe = RegExp(r'{:(?<groupId>\d+)_(?<id>\d+):}');

  /// Get the cache info related to [imageUrl].
  ImageEntity? getCacheInfo(String imageUrl) =>
      getIt.get<StorageProvider>().getImageCacheSync(imageUrl);

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
  Future<void> updateCache(String imageUrl, Uint8List imageData) async {
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

  int _calculateDirectorySize(Directory dir) {
    final fileList = dir.listSync(recursive: true);
    return fileList.fold<int>(0, (acc, x) {
      return acc + x.statSync().size;
    });
  }

  /// Calculate cache size in bytes.
  Future<CacheStorageInfo> calculateCache() async {
    final imageSize = _calculateDirectorySize(_imageCacheDirectory);
    final emojiSize = _calculateDirectorySize(_emojiCacheDirectory);
    return CacheStorageInfo(imageSize: imageSize, emojiSize: emojiSize);
  }

  /// Clear cache in [_imageCacheDirectory].
  Future<void> clearCache(CacheClearInfo clearInfo) async {
    if (clearInfo.clearImage) {
      await getIt.get<StorageProvider>().clearImageCache();
      for (final f in _imageCacheDirectory.listSync()) {
        await f.delete(recursive: true);
      }
    }
    if (clearInfo.clearEmoji) {
      for (final f in _emojiCacheDirectory.listSync()) {
        await f.delete(recursive: true);
      }
    }
  }

  ///////////////////////// Emoji Cache /////////////////////////

  /// Validate emoji cache.
  ///
  /// * Check the existence of cache folder and cache info file.
  /// * Check the all emojis described in emoji info file.
  ///
  /// # Return Value
  ///
  /// Return true when passed validation.
  /// Return false when failed the validation.
  Future<bool> validateEmojiCache() async {
    // Check cache directory and emoji info file exists or not.
    if (!_emojiCacheDirectory.existsSync() ||
        !_emojiCacheInfoFile.existsSync()) {
      return false;
    }
    try {
      final info = EmojiGroupListMapper.fromJson(
        await _emojiCacheInfoFile.readAsString(),
      );
      // Validate all cached emoji files exists.
      final validateResult = info.validateCache(_emojiCacheDirectory.path);
      return validateResult;
    } catch (e) {
      error('validate emoji cache failed: invalid emoji info: $e');
      return false;
    }
  }

  /// Save the emoji info.
  ///
  /// This is useful when reloading the emoji from cache.
  Future<void> saveEmojiInfo(List<EmojiGroup> emojiGroupList) async {
    final jsonData = EmojiGroupList(emojiGroupList).toJson();
    await _emojiCacheInfoFile.create(recursive: true);
    await _emojiCacheInfoFile.writeAsString(jsonData);
  }

  /// Load all emoji data from cache.
  ///
  ///
  /// Return null if no such cached emoji info or info is invalid.
  Future<List<EmojiGroup>?> loadEmojiInfo() async {
    if (!_emojiCacheInfoFile.existsSync()) {
      return null;
    }
    try {
      final info =
          EmojiGroupListMapper.fromJson(_emojiCacheInfoFile.readAsStringSync());
      return info.emojiGroupList;
    } catch (e) {
      error('failed to load emoji info when decoding json: $e');
      return null;
    }
  }

  /// Load emoji info and emoji images from assert.
  ///
  /// Copy to legacy emoji data dir so that existing emoji validation logic
  /// does not need to change.
  Future<List<EmojiGroup>?> loadEmojiFromAsset() async {
    final infoBytes = await rootBundle.loadString(assetEmojiInfoPath);
    final info = EmojiGroupListMapper.fromJson(infoBytes);
    await _emojiCacheInfoFile.writeAsString(infoBytes);

    for (final emojiGroup in info.emojiGroupList) {
      for (final emoji in emojiGroup.emojiList) {
        // All emoji are saved with ".jpg" suffix.
        final emojiBytes = await rootBundle.load(
          '$assetEmojiDir${emojiGroup.id}_${emoji.id}.jpg',
        );
        final cacheTarget =
            '${_emojiCacheDirectory.path}/${emojiGroup.id}_${emoji.id}.jpg';
        await File(cacheTarget).writeAsBytes(emojiBytes.buffer.asUint8List());
      }
    }

    return info.emojiGroupList;
  }

  /// Emoji cache is save as jpg file no matter the real content.
  String _formatEmojiCachePath(String groupId, String id) =>
      '${_emojiCacheDirectory.path}/${groupId}_$id.jpg';

  /// Check have the cache file for emoji with [groupId] and [id].
  bool hasEmojiCacheFile(String groupId, String id) {
    final cacheFile = File(_formatEmojiCachePath(groupId, id));
    return cacheFile.existsSync();
  }

  /// Try get the emoji cache from raw bbcode.
  ///
  /// Only valid when code in {:${GROUP_ID}_${EMOJI_ID}:} format.
  Future<Uint8List?> getEmojiCacheFromRawCode(String code) async {
    if (!_emojiCodeRe.hasMatch(code)) {
      return null;
    }
    final m = _emojiCodeRe.firstMatch(code)!;
    final groupId = m.namedGroup('groupId')!;
    final id = m.namedGroup('id')!;
    return getEmojiCache(groupId, id);
  }

  /// Try get the emoji cache from raw bbcode.
  ///
  /// Synchronously.
  Uint8List? getEmojiCacheFromRawCodeSync(String code) {
    if (!_emojiCodeRe.hasMatch(code)) {
      return null;
    }
    final m = _emojiCodeRe.firstMatch(code)!;
    final groupId = m.namedGroup('groupId')!;
    final id = m.namedGroup('id')!;
    return getEmojiCacheSync(groupId, id);
  }

  /// Get the cached file of emoji with specified [groupId] and [id].
  Future<Uint8List?> getEmojiCache(String groupId, String id) async {
    final cacheFile = File(_formatEmojiCachePath(groupId, id));
    if (!cacheFile.existsSync()) {
      error('$cacheFile cache file not exists');
      return null;
    }
    return cacheFile.readAsBytes();
  }

  /// Get the cached file of emoji with specified [groupId] and [id].
  Uint8List? getEmojiCacheSync(String groupId, String id) {
    final cacheFile = File(_formatEmojiCachePath(groupId, id));
    if (!cacheFile.existsSync()) {
      error('$cacheFile cache file not exists');
      return null;
    }
    return cacheFile.readAsBytesSync();
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
