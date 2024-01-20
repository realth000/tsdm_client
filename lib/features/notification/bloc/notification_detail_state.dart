import 'package:equatable/equatable.dart';
import 'package:tsdm_client/shared/models/post.dart';
import 'package:tsdm_client/shared/models/reply_parameters.dart';

enum NotificationDetailStatus {
  initial,
  loading,
  success,
  failed,
}

final class NotificationDetailState extends Equatable {
  const NotificationDetailState({
    this.status = NotificationDetailStatus.initial,
    this.post,
    this.pid,
    this.tid,
    this.page,
    this.replyParameters,
  });

  /// Detail page status.
  final NotificationDetailStatus status;

  /// Current carrying post.
  final Post? post;

  final String? tid;
  final String? pid;
  final String? page;

  /// Parameters to reply to current carrying [Post].
  final ReplyParameters? replyParameters;

  NotificationDetailState copyWith({
    NotificationDetailStatus? status,
    Post? post,
    ReplyParameters? replyParameters,
    String? tid,
    String? pid,
    String? page,
  }) {
    return NotificationDetailState(
      status: status ?? this.status,
      post: post ?? this.post,
      replyParameters: replyParameters ?? this.replyParameters,
      tid: tid ?? this.tid,
      pid: pid ?? this.pid,
      page: page ?? this.page,
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
      ];
}
