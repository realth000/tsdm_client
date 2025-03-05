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
  failure,
}

/// State of thread.
@MappableClass()
class ThreadState with ThreadStateMappable {
  /// Constructor.
  const ThreadState({
    this.tid,
    this.pid,
    this.status = ThreadStatus.initial,
    this.title,
    this.fid,
    this.forumName,
    this.canLoadMore = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.havePermission = true,
    this.permissionDeniedMessage,
    this.needLogin = false,
    this.threadSoftClosed = false,
    this.threadClosed = false,
    this.postList = const [],
    this.replyParameters,
    this.threadType,
    this.onlyVisibleUid,
    this.reverseOrder,
    this.exactOrder,
    this.isDraft = false,
    this.latestModAct,
    this.breadcrumbs = const [],
  });

  /// Status.
  final ThreadStatus status;

  /// Thread id.
  final String? tid;

  /// Post id.
  ///
  /// Use this when "mod=redirect&goto=findpost&pid=[pid]".
  ///
  /// Necessary info that always be parsed in thread page.
  /// May be null at the beginning of state but will be set shortly after it.
  final String? pid;

  /// Thread title.
  ///
  /// Necessary info that always be parsed in thread page.
  /// May be null at the beginning of state but will be set shortly after it.
  final String? title;

  /// Forum id.
  ///
  /// Necessary info that always be parsed in thread page.
  /// May be null at the beginning of state but will be set shortly after it.
  final int? fid;

  /// Forum name.
  ///
  /// Necessary info that always be parsed in thread page.
  /// May be null at the beginning of state but will be set shortly after it.
  final String? forumName;

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

  /// A soft closed state only means the thread is locked.
  ///
  /// Like soft lock, soft closed is a state where the thread is closed but the user may still has write permission
  /// (For example, user is the moderator of current subreddit).
  ///
  /// In this state we shall keep the post functionality as the prerequisites are still satisfied, but give a tip that
  /// the thread is closed and maybe it's not proper to post again.
  final bool threadSoftClosed;

  /// Indicating current thread is closed or not.
  final bool threadClosed;

  /// List of [Post] in current thread.
  final List<Post> postList;

  /// Parameters used to reply to another post in the same thread.
  ///
  /// Save in state and should pass to reply bar.
  final ReplyParameters? replyParameters;

  /// Thread type.
  ///
  /// Usually a thread belongs to a fixed of list of thread types in the current subreddit. But some are not.
  final FilterType? threadType;

  /// Indicating only show posts published by the user who has the given uid
  /// in current thread.
  ///
  /// Show all posts if value is null;
  final String? onlyVisibleUid;

  /// View posts in current thread in forward order or reverse order.
  ///
  /// * Force set to desc order if `true`.
  /// * Force set to asc order if `false`.
  /// * Not force order if `null`.
  final bool? reverseOrder;

  /// The exact thread order in state.
  ///
  /// Specify this field if want to override with the app one.
  final int? exactOrder;

  /// Indicating current thread is a draft or not.
  final bool isDraft;

  /// Latest modification log.
  final String? latestModAct;

  /// All breadcrumbs that describe the position of current thread.
  ///
  /// It's ordered so held by a list and more right side more deep.
  final List<ThreadBreadcrumb> breadcrumbs;
}
