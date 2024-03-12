part of 'models.dart';

/// All emoji group save in cache.
///
/// Wrapper class to save to/from json with cache.
@MappableClass()
class EmojiGroupList with EmojiGroupListMappable {
  /// Constructor.
  const EmojiGroupList(this.emojiGroupList);

  /// All emoji groups
  final List<EmojiGroup> emojiGroupList;

  /// Validate the emoji cache in [rootDir].
  ///
  /// Return true when all emoji cache file exists.
  bool validateCache(String rootDir) {
    for (final emojiGroup in emojiGroupList) {
      for (final emoji in emojiGroup.emojiList) {
        final cachePath = '$rootDir/${emojiGroup.id}_${emoji.id}.jpg';
        if (!File(cachePath).existsSync()) {
          debug('invalid emoji at $cachePath');
          return false;
        }
      }
    }
    return true;
  }
}
