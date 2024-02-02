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

/// User requested to only view the posts published by user with [uid] in
/// current thread.
///
/// Note that triggering this event **will not change the current page number**.
/// We behave like what it acts in browser.
final class ThreadOnlyViewAuthorRequested extends ThreadEvent {
  /// Constructor.
  const ThreadOnlyViewAuthorRequested(this.uid);

  /// The only author to view in current thread.
  final String uid;
}

/// User requested to view posts published by all authors in current thread.
///
/// This is the default behavior when display threads.
///
/// Note that triggering this event **will not change the current page number**.
/// We behave like what it acts in browser.
final class ThreadViewAllAuthorsRequested extends ThreadEvent {}

/// User requested to change the order when viewing posts in current thread.
///
/// The default behavior is forward order.
///
/// Note that the "reversed order" seems conflict with "only view specified
/// user" on the server side on UI, but here do implement it by reserving both
/// query parameters in thread url so there is no conflict any more. Different
/// from the behavior in browser but it's ok, even better.
final class ThreadChangeViewOrderRequested extends ThreadEvent {
  /// Constructor.
  const ThreadChangeViewOrderRequested();
}
