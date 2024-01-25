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
    this.needClearText = false,
  });

  final ReplyStatus status;
  final ReplyParameters? replyParameters;

  /// Indicating can send reply or not.
  ///
  /// If true, current reply bar should be closed, because maybe the thread is closed.
  final bool closed;

  /// Indicating need to clear the text in reply text field.
  ///
  /// This should be set to true once sending request success, only one time.
  final bool needClearText;

  ReplyState copyWith({
    ReplyStatus? status,
    ReplyParameters? replyParameters,
    bool? closed,
    bool? needClearText,
  }) {
    return ReplyState(
      status: status ?? this.status,
      replyParameters: replyParameters ?? this.replyParameters,
      closed: closed ?? this.closed,
      needClearText: needClearText ?? this.needClearText,
    );
  }

  ReplyState copyWithNullReplyParameters() {
    return ReplyState(
      status: status,
      replyParameters: null,
      closed: closed,
      needClearText: needClearText,
    );
  }

  @override
  List<Object?> get props => [status, replyParameters, closed, needClearText];
}
