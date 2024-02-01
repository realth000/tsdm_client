part of 'latest_thread_bloc.dart';

/// Events of latest thread feature.
sealed class LatestThreadEvent extends Equatable {
  const LatestThreadEvent();

  @override
  List<Object?> get props => [];
}

/// No more page to load.
final class LatestThreadLoadMoreRequested extends LatestThreadEvent {}

/// User request to refresh.
final class LatestThreadRefreshRequested extends LatestThreadEvent {
  /// Constructor.
  const LatestThreadRefreshRequested(this.url) : super();

  /// Url to load page.
  final String url;
}
