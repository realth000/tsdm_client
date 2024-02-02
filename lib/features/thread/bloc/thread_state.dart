part of 'thread_bloc.dart';

/// Status of thread.
enum ThreadStatus {
  /// Initial.
  initial,

  /// Loading date for the first time.
  loading,

  /// Load succeed.
  success,

  /// Load failed.
  failed,
}

/// State of thread.
class ThreadState extends Equatable {
  /// Constructor.
  const ThreadState({
    required this.tid,
    this.status = ThreadStatus.initial,
    this.title,
    this.canLoadMore = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.havePermission = true,
    this.permissionDeniedMessage,
    this.needLogin = false,
    this.threadClosed = false,
    this.postList = const [],
    this.replyParameters,
    this.threadType,
    this.onlyVisibleUid,
  });

  /// Status.
  final ThreadStatus status;

  /// Thread id.
  final String tid;

  /// Thread title.
  final String? title;

  /// Flag indicating can load more pages or not.
  final bool canLoadMore;

  /// Current pageNumber
  final int currentPage;

  /// Total pages number in the thread.
  final int totalPages;

  /// Flag indicating current user has permission to see this page or not.
  ///
  /// Only works with logged user. If no user logged in, use [needLogin] flag
  /// instead.
  final bool havePermission;

  /// Message showed from server when have no permission.
  final uh.Element? permissionDeniedMessage;

  /// Flag indicating whether need to login to see this page or not.
  ///
  /// Only works when no user logged.
  final bool needLogin;

  /// Indicating current thread is closed or not.
  final bool threadClosed;

  /// List of [Post] in current thread.
  final List<Post> postList;

  /// Parameters used to reply to another post in the same thread.
  ///
  /// Save in state and should pass to reply bar.
  final ReplyParameters? replyParameters;

  /// Thread type.
  final String? threadType;

  /// Indicating only show posts published by the user who has the given uid
  /// in current thread.
  ///
  /// Show all posts if value is null;
  final String? onlyVisibleUid;

  /// Copy with.
  ThreadState copyWith({
    ThreadStatus? status,
    String? tid,
    String? title,
    bool? canLoadMore,
    int? currentPage,
    int? totalPages,
    bool? havePermission = true,
    uh.Element? permissionDeniedMessage,
    bool? needLogin,
    bool? threadClosed,
    List<Post>? postList,
    ReplyParameters? replyParameters,
    String? onlyVisibleUid,
  }) {
    return ThreadState(
      status: status ?? this.status,
      tid: tid ?? this.tid,
      title: title ?? this.title,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      havePermission: havePermission ?? this.havePermission,
      permissionDeniedMessage:
          permissionDeniedMessage ?? this.permissionDeniedMessage,
      needLogin: needLogin ?? this.needLogin,
      threadClosed: threadClosed ?? this.threadClosed,
      postList: postList ?? this.postList,
      replyParameters: replyParameters ?? this.replyParameters,
      onlyVisibleUid: onlyVisibleUid ?? this.onlyVisibleUid,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tid,
        title,
        canLoadMore,
        currentPage,
        totalPages,
        havePermission,
        permissionDeniedMessage,
        needLogin,
        threadClosed,
        postList,
        replyParameters,
        onlyVisibleUid,
      ];
}
