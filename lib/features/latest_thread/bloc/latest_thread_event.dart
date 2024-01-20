part of 'latest_thread_bloc.dart';

sealed class LatestThreadEvent extends Equatable {
  const LatestThreadEvent();

  @override
  List<Object?> get props => [];
}

final class LatestThreadLoadMoreRequested extends LatestThreadEvent {}

final class LatestThreadRefreshRequested extends LatestThreadEvent {
  const LatestThreadRefreshRequested(this.url) : super();
  final String url;
}
