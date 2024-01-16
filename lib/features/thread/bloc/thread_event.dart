part of 'thread_bloc.dart';

sealed class ThreadEvent extends Equatable {
  const ThreadEvent();

  @override
  List<Object?> get props => [];
}

final class ThreadRefreshRequested extends ThreadEvent {}

final class ThreadLoadMoreRequested extends ThreadEvent {
  const ThreadLoadMoreRequested(this.pageNumber) : super();

  final int pageNumber;

  @override
  List<Object?> get props => [pageNumber];
}

/// User request to jump to another page.
final class ThreadJumpPageRequested extends ThreadEvent {
  const ThreadJumpPageRequested(this.pageNumber) : super();
  final int pageNumber;

  @override
  List<Object?> get props => [pageNumber];
}

/// Mark thread as closed or not.
///
/// Closed threads should disable the reply bar.
///
/// Persistent in state.
final class ThreadClosedStateUpdated extends ThreadEvent {
  const ThreadClosedStateUpdated({required this.closed}) : super();
  final bool closed;

  @override
  List<Object?> get props => [closed];
}

/// Clear current reply parameters.
final class ThreadClearReplyParameterRequested extends ThreadEvent {}
