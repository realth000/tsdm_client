import 'package:equatable/equatable.dart';
import 'package:tsdm_client/shared/models/post.dart';
import 'package:tsdm_client/shared/models/reply_parameters.dart';

/// Status of notification detail.
enum NotificationDetailStatus {
  /// Inital status.
  initial,

  /// Loading data.
  loading,

  /// Load succeed.
  success,

  /// Load failed.
  failed,
}

/// State of notification detail.
final class NotificationDetailState extends Equatable {
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

  /// Coresponding post id of the current notification.
  final String? pid;

  /// Thread page number that contains the related post.
  final String? page;

  /// Parameters to reply to current carrying [Post].
  final ReplyParameters? replyParameters;

  /// Flag indicating current thread is closed or not.
  final bool threadClosed;

  /// Copy with.
  NotificationDetailState copyWith({
    NotificationDetailStatus? status,
    Post? post,
    ReplyParameters? replyParameters,
    String? tid,
    String? pid,
    String? page,
    bool? threadClosed,
  }) {
    return NotificationDetailState(
      status: status ?? this.status,
      post: post ?? this.post,
      replyParameters: replyParameters ?? this.replyParameters,
      tid: tid ?? this.tid,
      pid: pid ?? this.pid,
      page: page ?? this.page,
      threadClosed: threadClosed ?? this.threadClosed,
    );
  }

  @override
  List<Object?> get props => [
        status,
        post,
        replyParameters,
        tid,
        pid,
        page,
        threadClosed,
      ];
}
