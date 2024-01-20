part of 'my_thread_bloc.dart';

enum MyThreadStatus {
  initial,

  /// This loading state only presents when first enter MyThread page.
  ///
  /// Means loading the initial data.
  ///
  /// After refresh and loading more pages will stay in success state.
  loading,
  success,
  failed,
}

final class MyThreadState extends Equatable {
  const MyThreadState({
    this.status = MyThreadStatus.initial,
    this.threadList = const [],
    this.threadPageNumber = 1,
    this.nextThreadPageUrl,
    this.refreshingThread = false,
    this.replyList = const [],
    this.replyPageNumber = 1,
    this.nextReplyPageUrl,
    this.refreshingReply = false,
  });

  final MyThreadStatus status;

  /// List of [MyThread] contains threads in thread tab.
  final List<MyThread> threadList;

  final int threadPageNumber;

  final String? nextThreadPageUrl;

  /// Flag indicates refreshing thread tab.
  final bool refreshingThread;

  /// List of [MyThread] contains replies in reply tab.
  final List<MyThread> replyList;

  final int replyPageNumber;

  final String? nextReplyPageUrl;

  /// Flag indicates refreshing reply tab.
  final bool refreshingReply;

  MyThreadState copyWith({
    MyThreadStatus? status,
    List<MyThread>? threadList,
    int? threadPageNumber,
    String? nextThreadPageUrl,
    bool? refreshingThread,
    List<MyThread>? replyList,
    int? replyPageNumber,
    String? nextReplyPageUrl,
    bool? refreshingReply,
  }) {
    return MyThreadState(
      status: status ?? this.status,
      threadList: threadList ?? this.threadList,
      threadPageNumber: threadPageNumber ?? this.threadPageNumber,
      nextThreadPageUrl: nextThreadPageUrl ?? this.nextThreadPageUrl,
      refreshingThread: refreshingThread ?? this.refreshingThread,
      replyList: replyList ?? this.replyList,
      replyPageNumber: replyPageNumber ?? this.replyPageNumber,
      nextReplyPageUrl: nextReplyPageUrl ?? this.nextReplyPageUrl,
      refreshingReply: refreshingReply ?? this.refreshingReply,
    );
  }

  @override
  List<Object?> get props => [
        status,
        threadList,
        threadPageNumber,
        nextThreadPageUrl,
        refreshingThread,
        replyList,
        replyPageNumber,
        nextReplyPageUrl,
        refreshingReply,
      ];
}
