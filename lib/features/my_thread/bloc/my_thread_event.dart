part of 'my_thread_bloc.dart';

sealed class MyThreadEvent extends Equatable {
  const MyThreadEvent();

  @override
  List<Object?> get props => [];
}

/// Load the initial data for the very first time.
///
/// NEVER trigger this manually.
final class MyThreadLoadInitialDataRequested extends MyThreadEvent {}

final class MyThreadLoadMoreThreadRequested extends MyThreadEvent {
  const MyThreadLoadMoreThreadRequested() : super();
}

final class MyThreadLoadMoreReplyRequested extends MyThreadEvent {
  const MyThreadLoadMoreReplyRequested() : super();
}

final class MyThreadRefreshThreadRequested extends MyThreadEvent {}

final class MyThreadRefreshReplyRequested extends MyThreadEvent {}
