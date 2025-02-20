part of 'models.dart';

/// Represent an emoji.
@MappableClass()
class Emoji with EmojiMappable {
  /// Constructor.
  const Emoji({required this.id, required this.code, required this.url});

  /// Id in emoji group.
  final String id;

  /// BBCode.
  final String code;

  /// Url to get the emoji image.
  final String url;
}

/// A group of [Emoji].
@MappableClass()
class EmojiGroup with EmojiGroupMappable {
  /// Constructor.
  const EmojiGroup({required this.name, required this.id, required this.routeName, required this.emojiList});

  /// Human readable name.
  final String name;

  /// Group id.
  final String id;

  /// Part of the url to get emoji image.
  ///
  /// Represent the group.
  final String routeName;

  /// All emoji in group.
  final List<Emoji> emojiList;
}
