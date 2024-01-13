part of 'forum_bloc.dart';

/// Page status.
enum ForumStatus {
  initial,
  loading,
  success,
  failed,
}

/// State of forum page of the app.
class ForumState extends Equatable {
  const ForumState({
    required this.fid,
    this.status = ForumStatus.initial,
    this.stickThreadList = const [],
    this.normalThreadList = const [],
    this.subredditList = const [],
    this.canLoadMore = true,
    this.currentPage = 1,
    this.totalPages = 1,
    this.havePermission = true,
    this.permissionDeniedMessage,
    this.needLogin = false,
  });

  /// Page status.
  final ForumStatus status;

  /// Forum id.
  final String fid;

  /// Pinned thread in this forum.
  ///
  /// Only load in the first page and never update because other numbers of pages do not have pinned threads at all.
  final List<StickThread> stickThreadList;

  final List<NormalThread> normalThreadList;

  /// All subreddits in this forum.
  ///
  /// All subreddits are in expanded layout.
  final List<Forum> subredditList;

  /// Flag indicating can load more pages or not.
  final bool canLoadMore;

  /// Current pageNumber
  final int currentPage;

  final int totalPages;

  /// Flag indicating current user has permission to see this page or not.
  ///
  /// Only works with logged user. If no user logged in, use [needLogin] flag instead.
  final bool havePermission;

  /// Message showed from server when have no permission.
  final String? permissionDeniedMessage;

  /// Flag indicating whether need to login to see this page or not.
  ///
  /// Only works when no user logged.
  final bool needLogin;

  ForumState copyWith({
    ForumStatus? status,
    String? fid,
    List<StickThread>? stickThreadList,
    List<NormalThread>? normalThreadList,
    List<Forum>? subredditList,
    bool? canLoadMore,
    bool? havePermission,
    bool? needLogin,
    String? permissionDeniedMessage,
    int? currentPage,
    int? totalPages,
  }) {
    return ForumState(
      status: status ?? this.status,
      fid: fid ?? this.fid,
      stickThreadList: stickThreadList ?? this.stickThreadList,
      normalThreadList: normalThreadList ?? this.normalThreadList,
      subredditList: subredditList ?? this.subredditList,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      havePermission: havePermission ?? this.havePermission,
      needLogin: needLogin ?? this.needLogin,
      permissionDeniedMessage:
          permissionDeniedMessage ?? this.permissionDeniedMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object?> get props => [
        status,
        fid,
        stickThreadList,
        normalThreadList,
        subredditList,
        canLoadMore,
        havePermission,
        permissionDeniedMessage,
        currentPage,
        totalPages,
      ];
}
