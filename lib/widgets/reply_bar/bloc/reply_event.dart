part of 'reply_bloc.dart';

/// Event of reply
sealed class ReplyEvent extends Equatable {
  /// Constructor.
  const ReplyEvent();

  @override
  List<Object?> get props => [];
}

/// Parameters used in reply.
///
/// Because reply bar does not handle events about page refresh (html document
/// fetching), reply parameters are provided by external
/// blocs (e.g. ThreadBloc).
///
/// When those bloc parsed the latest reply parameters from html document,
/// they should call this event
/// to sync parameters with here.
final class ReplyParametersUpdated extends ReplyEvent {
  /// Constructor.
  const ReplyParametersUpdated(this.replyParameters) : super();

  /// Parameters used in posting the reply data.
  final ReplyParameters? replyParameters;
}

/// The thread, which contains current reply bar, is closed (or not) and can
/// not (or can) send replies.
///
/// Because reply bar does not handle events about page refresh (html document
/// fetching), thread closed state are provided by external
/// blocs. (e.g. ThreadBloc).
///
/// When those bloc parsed the latest reply parameters from html document, they
/// should call this event
/// to sync parameters with here.
final class ReplyThreadClosed extends ReplyEvent {
  /// Constructor.
  const ReplyThreadClosed({required this.closed}) : super();

  /// Thread is closed or not.
  final bool closed;
}

/// User required to reply to another post.
final class ReplyToPostRequested extends ReplyEvent {
  /// Constructor.
  const ReplyToPostRequested({
    required this.replyParameters,
    required this.replyAction,
    required this.replyMessage,
  }) : super();

  /// Parameters used in posting the reply data.
  final ReplyParameters replyParameters;

  /// Action parameter used in posting the reply data.
  final String replyAction;

  /// Message to reply.
  final String replyMessage;

  @override
  List<Object?> get props => [replyParameters, replyAction, replyMessage];
}

/// User required to reply to a thread.
final class ReplyToThreadRequested extends ReplyEvent {
  /// Constructor.
  const ReplyToThreadRequested({
    required this.replyParameters,
    required this.replyMessage,
  }) : super();

  /// Parameters used in posting the reply data.
  final ReplyParameters replyParameters;

  /// Message to reply.
  final String replyMessage;

  @override
  List<Object?> get props => [replyParameters, replyMessage];
}

/// This event is used to reset the state of flag needClearText in state.
///
/// That flag should only be true once when user send post succeed, then reset
/// to false.
final class ReplyResetClearTextStateTriggered extends ReplyEvent {}
