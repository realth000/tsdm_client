part of 'reply_bloc.dart';

sealed class ReplyEvent extends Equatable {
  const ReplyEvent();

  @override
  List<Object?> get props => [];
}

/// Parameters used in reply.
///
/// Because reply bar does not handle events about page refresh (html document fetching), reply parameters
/// are provided by external blocs (e.g. ThreadBloc).
///
/// When those bloc parsed the latest reply parameters from html document, they should call this event
/// to sync parameters with here.
final class ReplyParametersUpdated extends ReplyEvent {
  const ReplyParametersUpdated(this.replyParameters) : super();

  final ReplyParameters? replyParameters;
}

/// The thread, which contains current reply bar, is closed (or not) and can not (or can) send replies.
///
/// Because reply bar does not handle events about page refresh (html document fetching), thread closed state
/// are provided by external blocs. (e.g. ThreadBloc).
///
/// When those bloc parsed the latest reply parameters from html document, they should call this event
/// to sync parameters with here.
final class ReplyThreadClosed extends ReplyEvent {
  const ReplyThreadClosed({required this.closed}) : super();
  final bool closed;
}

final class ReplyToPostRequested extends ReplyEvent {
  const ReplyToPostRequested({
    required this.replyParameters,
    required this.replyAction,
    required this.replyMessage,
  }) : super();

  final ReplyParameters replyParameters;
  final String replyAction;
  final String replyMessage;

  @override
  List<Object?> get props => [replyParameters, replyAction, replyMessage];
}

final class ReplyToThreadRequested extends ReplyEvent {
  const ReplyToThreadRequested({
    required this.replyParameters,
    required this.replyMessage,
  }) : super();

  final ReplyParameters replyParameters;
  final String replyMessage;

  @override
  List<Object?> get props => [replyParameters, replyMessage];
}
