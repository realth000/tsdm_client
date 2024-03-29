part of 'reply_bloc.dart';

/// Status of reply
enum ReplyStatus {
  /// Initial.
  initial,

  ///  Posting reply.
  loading,

  /// Reply succeed.
  success,

  /// Reply failed.
  failed,
}

/// State of reply.
@MappableClass()
class ReplyState with ReplyStateMappable {
  /// Constructor.
  const ReplyState({
    this.status = ReplyStatus.initial,
    this.replyParameters,
    this.closed = true,
    this.needClearText = false,
  });

  /// Status.
  final ReplyStatus status;

  /// Parameter used in reply.
  final ReplyParameters? replyParameters;

  /// Indicating can send reply or not.
  ///
  /// If true, current reply bar should be closed, because maybe the thread
  /// is closed.
  final bool closed;

  /// Indicating need to clear the text in reply text field.
  ///
  /// This should be set to true once sending request success, only one time.
  final bool needClearText;

  /// Copy with, but make the `replyParameters` to null.
  ReplyState copyWithNullReplyParameters() {
    return ReplyState(
      status: status,
      closed: closed,
      needClearText: needClearText,
    );
  }
}
