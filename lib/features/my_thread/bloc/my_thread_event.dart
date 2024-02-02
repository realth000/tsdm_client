part of 'my_thread_bloc.dart';

/// Events in MyThread page.
sealed class MyThreadEvent extends Equatable {
  const MyThreadEvent();

  @override
  List<Object?> get props => [];
}

/// Load the initial data for the very first time.
///
/// NEVER trigger this manually.
final class MyThreadLoadInitialDataRequested extends MyThreadEvent {}

/// User requires to load more pages.
final class MyThreadLoadMoreThreadRequested extends MyThreadEvent {
  /// Constructor.
  const MyThreadLoadMoreThreadRequested() : super();
}

/// User requires to load more repliy pages.
final class MyThreadLoadMoreReplyRequested extends MyThreadEvent {
  /// Constructor.
  const MyThreadLoadMoreReplyRequested() : super();
}

/// User requires to refresh thread tab page.
final class MyThreadRefreshThreadRequested extends MyThreadEvent {}

/// User requires to refresh reply tab page.
final class MyThreadRefreshReplyRequested extends MyThreadEvent {}
