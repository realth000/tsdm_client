import 'dart:async';
import 'dart:typed_data';

import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';

/// Repository of global image cache.
final class ImageCacheRepository with LoggerMixin {
  /// Constructor.
  const ImageCacheRepository(this._imageCacheProvider);

  final ImageCacheProvider _imageCacheProvider;

  /// Update caches.
  ///
  /// When [force] is true, always ignore local cache and fetch image from url.
  FutureOr<void> updateImageCache(String url, {bool force = false}) async {
    await _imageCacheProvider.getOrMakeCache(ImageCacheGeneralRequest(url), force: force);
  }

  /// Get the cached file of emoji with specified [groupId] and [id].
  Uint8List? getEmojiCacheSync(String groupId, String id) {
    return _imageCacheProvider.getEmojiCacheSync(groupId, id);
  }

  /// Get emoji cache data form emoji bbcode [code].
  Future<Uint8List?> getEmojiCacheFromRawCode(String code) async {
    return _imageCacheProvider.getEmojiCacheFromRawCode(code);
  }

  /// Release resources.
  Future<void> dispose() async {
    await _imageCacheProvider.dispose();
  }
}
