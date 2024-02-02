import 'package:equatable/equatable.dart';
import 'package:tsdm_client/shared/models/forum.dart';

/// A group of [Forum].
final class ForumGroup extends Equatable {
  /// Constructor.
  const ForumGroup({
    required this.name,
    required this.url,
    required this.forumList,
  });

  /// Forum name.
  final String name;

  /// Forum url.
  final String url;

  /// All subreddit in the forum.
  final List<Forum> forumList;

  @override
  List<Object?> get props => [name, url, forumList];
}
