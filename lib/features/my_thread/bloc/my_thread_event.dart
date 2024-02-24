part of 'my_thread_bloc.dart';

/// Events in MyThread page.
@MappableClass()
sealed class MyThreadEvent with MyThreadEventMappable {
  const MyThreadEvent();
}

/// Load the initial data for the very first time.
///
/// NEVER trigger this manually.
@MappableClass()
final class MyThreadLoadInitialDataRequested extends MyThreadEvent
    with MyThreadLoadInitialDataRequestedMappable {}

/// User requires to load more pages.
@MappableClass()
final class MyThreadLoadMoreThreadRequested extends MyThreadEvent
    with MyThreadLoadMoreThreadRequestedMappable {
  /// Constructor.
  const MyThreadLoadMoreThreadRequested() : super();
}

/// User requires to load more reply pages.
@MappableClass()
final class MyThreadLoadMoreReplyRequested extends MyThreadEvent
    with MyThreadLoadMoreReplyRequestedMappable {
  /// Constructor.
  const MyThreadLoadMoreReplyRequested() : super();
}

/// User requires to refresh thread tab page.
@MappableClass()
final class MyThreadRefreshThreadRequested extends MyThreadEvent
    with MyThreadRefreshThreadRequestedMappable {}

/// User requires to refresh reply tab page.
@MappableClass()
final class MyThreadRefreshReplyRequested extends MyThreadEvent
    with MyThreadRefreshReplyRequestedMappable {}
