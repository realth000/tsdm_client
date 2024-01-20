part of 'latest_thread_bloc.dart';

enum LatestThreadStatus {
  initial,
  loading,
  success,
  failed,
}

final class LatestThreadState extends Equatable {
  const LatestThreadState({
    this.status = LatestThreadStatus.initial,
    this.threadList = const [],
    this.pageNumber = 1,
    this.nextPageUrl,
  });

  final LatestThreadStatus status;
  final List<LatestThread> threadList;
  final int pageNumber;
  final String? nextPageUrl;

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
