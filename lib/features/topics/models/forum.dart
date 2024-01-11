import 'package:equatable/equatable.dart';

/// Data model for subreddit.
final class Forum extends Equatable {
  const Forum({
    required this.forumID,
    required this.url,
    required this.name,
    required this.iconUrl,
    required this.threadCount,
    required this.replyCount,
    required this.latestThreadUrl,
    required this.latestThreadTime,
    required this.latestThreadTimeText,
    required this.threadTodayCount,

    /// Expanded layout only.
    this.subForumList,
    this.subThreadList,
    this.latestThreadTitle,
    this.latestThreadUserName,
    this.latestThreadUserUrl,
  });

  final int forumID;
  final String url;
  final String name;
  final String iconUrl;
  final int threadCount;
  final int replyCount;
  final String? latestThreadUrl;
  final DateTime? latestThreadTime;
  final String? latestThreadTimeText;
  final int? threadTodayCount;

  /// Expanded layout only.
  final List<(String subForumName, String url)>? subForumList;
  final List<(String threadTitle, String url)>? subThreadList;
  final String? latestThreadTitle;
  final String? latestThreadUserName;
  final String? latestThreadUserUrl;

  bool get isExpanded =>
      latestThreadTitle != null && latestThreadUserName != null;

  @override
  List<Object?> get props => [forumID];
}
