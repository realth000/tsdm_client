part of 'latest_thread_bloc.dart';

/// Events of latest thread feature.
@MappableClass()
sealed class LatestThreadEvent with LatestThreadEventMappable {
  const LatestThreadEvent();
}

/// No more page to load.
@MappableClass()
final class LatestThreadLoadMoreRequested extends LatestThreadEvent with LatestThreadLoadMoreRequestedMappable {}

/// User request to refresh.
@MappableClass()
final class LatestThreadRefreshRequested extends LatestThreadEvent with LatestThreadRefreshRequestedMappable {
  /// Constructor.
  const LatestThreadRefreshRequested(this.url) : super();

  /// Url to load page.
  final String url;
}
