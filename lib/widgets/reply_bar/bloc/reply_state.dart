part of 'reply_bloc.dart';

enum ReplyStatus {
  initial,
  loading,
  success,
  failed,
}

class ReplyState extends Equatable {
  const ReplyState({
    this.status = ReplyStatus.initial,
    this.replyParameters,
    this.closed = true,
  });

  final ReplyStatus status;
  final ReplyParameters? replyParameters;

  /// Indicating can send reply or not.
  ///
  /// If true, current reply bar should be closed, because maybe the thread is closed.
  final bool closed;

  ReplyState copyWith({
    ReplyStatus? status,
    ReplyParameters? replyParameters,
    bool? closed,
  }) {
    return ReplyState(
      status: status ?? this.status,
      replyParameters: replyParameters ?? this.replyParameters,
      closed: closed ?? this.closed,
    );
  }

  ReplyState copyWithNullReplyParameters() {
    return ReplyState(
      status: status,
      replyParameters: null,
      closed: closed,
    );
  }

  @override
  List<Object?> get props => [status, replyParameters, closed];
}
