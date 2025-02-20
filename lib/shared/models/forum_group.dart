part of 'models.dart';

/// A group of [Forum].
@MappableClass()
final class ForumGroup with ForumGroupMappable {
  /// Constructor.
  const ForumGroup({required this.name, required this.url, required this.forumList});

  /// Forum name.
  final String name;

  /// Forum url.
  final String url;

  /// All subreddit in the forum.
  final List<Forum> forumList;
}
