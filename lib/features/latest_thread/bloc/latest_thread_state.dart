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
final class LatestThreadState extends Equatable {
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

  /// Copy with
  LatestThreadState copyWith({
    LatestThreadStatus? status,
    List<LatestThread>? threadList,
    int? pageNumber,
    String? nextPageUrl,
  }) {
    return LatestThreadState(
      status: status ?? this.status,
      threadList: threadList ?? this.threadList,
      pageNumber: pageNumber ?? this.pageNumber,
      nextPageUrl: nextPageUrl ?? this.nextPageUrl,
    );
  }

  @override
  List<Object?> get props => [status, threadList, pageNumber, nextPageUrl];
}
