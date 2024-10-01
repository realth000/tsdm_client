part of 'models.dart';

/// A record of a given user of [uid] visited thread which has [threadId] at
/// time [visitTime].
@MappableClass()
final class ThreadVisitHistoryModel with ThreadVisitHistoryModelMappable {
  /// Constructor.
  const ThreadVisitHistoryModel({
    required this.uid,
    required this.username,
    required this.threadId,
    required this.threadTitle,
    required this.forumId,
    required this.forumName,
    required this.visitTime,
  });

  /// User id of who visited the thread.
  final int uid;

  /// User name of who visited the thread.
  final String username;

  /// ID of thread that visited.
  final int threadId;

  /// Title of thread that visited.
  final String threadTitle;

  /// Id of the forum that owns the thread.
  final int forumId;

  /// Name of the forum that owns the thread.
  final String forumName;

  /// Last visit time.
  final DateTime visitTime;
}
