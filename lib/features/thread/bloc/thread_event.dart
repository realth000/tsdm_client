part of 'thread_bloc.dart';

/// Event of thread page.
@MappableClass()
sealed class ThreadEvent with ThreadEventMappable {
  /// Constructor.
  const ThreadEvent();
}

/// User requested to refresh the page.
@MappableClass()
final class ThreadRefreshRequested extends ThreadEvent
    with ThreadRefreshRequestedMappable {}

/// User requested to load more thread pages.
@MappableClass()
final class ThreadLoadMoreRequested extends ThreadEvent
    with ThreadLoadMoreRequestedMappable {
  /// Constructor.
  const ThreadLoadMoreRequested(this.pageNumber) : super();

  /// Page number to load.
  final int pageNumber;
}

/// User request to jump to another page.
@MappableClass()
final class ThreadJumpPageRequested extends ThreadEvent
    with ThreadJumpPageRequestedMappable {
  /// Constructor.
  const ThreadJumpPageRequested(this.pageNumber) : super();

  /// Page number to jump to.
  final int pageNumber;
}

/// Mark thread as closed or not.
///
/// Closed threads should disable the reply bar.
///
/// Persistent in state.
@MappableClass()
final class ThreadClosedStateUpdated extends ThreadEvent
    with ThreadClosedStateUpdatedMappable {
  /// Constructor.
  const ThreadClosedStateUpdated({required this.closed}) : super();

  /// Current thread is closed or not.
  final bool closed;
}

/// Clear current reply parameters.
@MappableClass()
final class ThreadClearReplyParameterRequested extends ThreadEvent
    with ThreadClearReplyParameterRequestedMappable {}

/// User requested to only view the posts published by user with [uid] in
/// current thread.
///
/// Note that triggering this event **will not change the current page number**.
/// We behave like what it acts in browser.
@MappableClass()
final class ThreadOnlyViewAuthorRequested extends ThreadEvent
    with ThreadOnlyViewAuthorRequestedMappable {
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
@MappableClass()
final class ThreadViewAllAuthorsRequested extends ThreadEvent
    with ThreadViewAllAuthorsRequestedMappable {}

/// User requested to change the order when viewing posts in current thread.
///
/// The default behavior is forward order.
///
/// Note that the "reversed order" seems conflict with "only view specified
/// user" on the server side on UI, but here do implement it by reserving both
/// query parameters in thread url so there is no conflict any more. Different
/// from the behavior in browser but it's ok, even better.
@MappableClass()
final class ThreadChangeViewOrderRequested extends ThreadEvent
    with ThreadChangeViewOrderRequestedMappable {
  /// Constructor.
  const ThreadChangeViewOrderRequested();
}
