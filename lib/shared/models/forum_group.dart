import 'package:equatable/equatable.dart';
import 'package:tsdm_client/features/topics/models/forum.dart';

/// A group of [Forum].
final class ForumGroup extends Equatable {
  const ForumGroup({
    required this.name,
    required this.url,
    required this.forumList,
  });

  final String name;
  final String url;
  final List<Forum> forumList;

  @override
  List<Object?> get props => [name, url, forumList];
}
