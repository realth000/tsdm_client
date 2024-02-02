part of 'thread_bloc.dart';

/// Event of thread page.
sealed class ThreadEvent extends Equatable {
  /// Constructor.
  const ThreadEvent();

  @override
  List<Object?> get props => [];
}

/// User requested to refresh the page.
final class ThreadRefreshRequested extends ThreadEvent {}

/// User requested to load more thread pages.
final class ThreadLoadMoreRequested extends ThreadEvent {
  /// Constructor.
  const ThreadLoadMoreRequested(this.pageNumber) : super();

  /// Page number to load.
  final int pageNumber;

  @override
  List<Object?> get props => [pageNumber];
}

/// User request to jump to another page.
final class ThreadJumpPageRequested extends ThreadEvent {
  /// Constructor.
  const ThreadJumpPageRequested(this.pageNumber) : super();

  /// Page number to jump to.
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
  /// Constructor.
  const ThreadClosedStateUpdated({required this.closed}) : super();

  /// Current thread is closed or not.
  final bool closed;

  @override
  List<Object?> get props => [closed];
}

/// Clear current reply parameters.
final class ThreadClearReplyParameterRequested extends ThreadEvent {}
