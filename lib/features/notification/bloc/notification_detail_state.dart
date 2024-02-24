part of 'notification_detail_cubit.dart';

/// Status of notification detail.
enum NotificationDetailStatus {
  /// Initial status.
  initial,

  /// Loading data.
  loading,

  /// Load succeed.
  success,

  /// Load failed.
  failed,
}

/// State of notification detail.
@MappableClass()
final class NotificationDetailState with NotificationDetailStateMappable {
  /// Constructor.
  const NotificationDetailState({
    this.status = NotificationDetailStatus.initial,
    this.post,
    this.pid,
    this.tid,
    this.page,
    this.replyParameters,
    this.threadClosed = true,
  });

  /// Detail page status.
  final NotificationDetailStatus status;

  /// Current carrying post.
  final Post? post;

  /// Thread id the current notification belongs to.
  final String? tid;

  /// Corresponding post id of the current notification.
  final String? pid;

  /// Thread page number that contains the related post.
  final String? page;

  /// Parameters to reply to current carrying [Post].
  final ReplyParameters? replyParameters;

  /// Flag indicating current thread is closed or not.
  final bool threadClosed;
}
