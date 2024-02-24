part of 'forum_bloc.dart';

/// Page status.
enum ForumStatus {
  /// Initial.
  initial,

  /// Loading.
  loading,

  /// Load succeed.
  success,

  /// Failed to load.
  failed;

  /// Is loading data.
  bool isLoading() => this == initial || this == loading;
}

/// State of forum page of the app.
@MappableClass()
class ForumState with ForumStateMappable {
  /// Constructor.
  const ForumState({
    required this.fid,
    this.title,
    this.status = ForumStatus.initial,
    this.rulesElement,
    this.stickThreadList = const [],
    this.normalThreadList = const [],
    this.subredditList = const [],
    this.canLoadMore = true,
    this.currentPage = 1,
    this.totalPages = 1,
    this.havePermission = true,
    this.permissionDeniedMessage,
    this.needLogin = false,
    this.filterState = const FilterState(),
    this.filterTypeList = const [],
    this.filterSpecialTypeList = const [],
    this.filterOrderList = const [],
    this.filterDatelineList = const [],
  });

  /// Page status.
  final ForumStatus status;

  /// Forum id.
  final String fid;

  /// Forum title.
  final String? title;

  /// Html element of forum rules node.
  final uh.Element? rulesElement;

  /// Pinned thread in this forum.
  ///
  /// Only load in the first page and never update because other numbers of
  /// pages do not have pinned threads at all.
  final List<StickThread> stickThreadList;

  /// All normal thread list.
  final List<NormalThread> normalThreadList;

  /// All subreddits in this forum.
  ///
  /// All subreddits are in expanded layout.
  final List<Forum> subredditList;

  /// Flag indicating can load more pages or not.
  final bool canLoadMore;

  /// Current pageNumber
  final int currentPage;

  /// How many pages in this forum
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

  /// State of thread filter.
  final FilterState filterState;

  /// All available [FilterType] list.
  final List<FilterType> filterTypeList;

  /// All available [FilterSpecialType] list.
  final List<FilterSpecialType> filterSpecialTypeList;

  /// All available [FilterOrder] list.
  final List<FilterOrder> filterOrderList;

  /// All available [FilterDateline] list.
  final List<FilterDateline> filterDatelineList;
}
