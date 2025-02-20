part of 'models.dart';

/// Information about cache storage.
@MappableClass()
final class CacheStorageInfo with CacheStorageInfoMappable {
  /// Constructor.
  const CacheStorageInfo({required this.imageSize, required this.emojiSize});

  /// Image cache size in bytes.
  final int imageSize;

  /// Emoji cache size in bytes.
  final int emojiSize;
}

/// Model representing what kinds of cache to clear in a action.
@MappableClass()
final class CacheClearInfo with CacheClearInfoMappable {
  /// Constructor.
  const CacheClearInfo({required this.clearImage, required this.clearEmoji});

  /// Clear image cache.
  final bool clearImage;

  /// Clear emoji cache.
  final bool clearEmoji;

  /// Default configs for different kinds of cache.
  static const defaultCacheClearInfo = CacheClearInfo(clearImage: true, clearEmoji: false);

  /// Any kind of cache selected.
  bool get hasSelected => clearImage || clearEmoji;
}
