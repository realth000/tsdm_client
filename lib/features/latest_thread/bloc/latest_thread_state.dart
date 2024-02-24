part of 'latest_thread_bloc.dart';

/// Status of the latest thread feature.
enum LatestThreadStatus {
  /// Initial.
  initial,

  /// Loading.
  loading,

  /// Success.
  success,

  /// Failed to load.
  failed,
}

/// State of the latest thread feature.
@MappableClass()
final class LatestThreadState with LatestThreadStateMappable {
  /// Constructor.
  const LatestThreadState({
    this.status = LatestThreadStatus.initial,
    this.threadList = const [],
    this.pageNumber = 1,
    this.nextPageUrl,
  });

  /// Status.
  final LatestThreadStatus status;

  /// All thread to display.
  final List<LatestThread> threadList;

  /// Current page number.
  final int pageNumber;

  /// Url to fetch the next page.
  final String? nextPageUrl;
}
