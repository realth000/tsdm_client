part of 'homepage_bloc.dart';

/// Data status of the homepage of the app (the first tab in home).
enum HomepageStatus {
  /// Initial state.
  initial,

  /// Need to login.
  ///
  /// This state should be check first before loading data.
  needLogin,

  /// Loading the page.
  loading,

  /// Load data finished.
  success,

  /// Failed to load data.
  failed;

  /// Is [initial]?
  bool get isInitial => this == HomepageStatus.initial;

  /// Is [needLogin]?
  bool get isNeedLogin => this == HomepageStatus.needLogin;

  /// Is [loading]?
  bool get isLoading => this == HomepageStatus.loading;

  /// Is [success]?
  bool get isSuccess => this == HomepageStatus.success;

  /// Is [failed]?
  bool get isFailed => this == HomepageStatus.failed;
}

/// State of homepage.
final class HomepageState extends Equatable {
  /// Constructor.
  const HomepageState({
    this.status = HomepageStatus.initial,
    this.forumStatus = const ForumStatus.empty(),
    this.loggedUserInfo,
    this.pinnedThreadGroupList = const [],
    this.swiperUrlList = const [],
    this.unreadNoticeCount = 0,
    this.hasUnreadMessage = false,
  });

  /// Loading status.
  final HomepageStatus status;

  /// Forum statistics status.
  final ForumStatus forumStatus;

  /// Current logged user info.
  ///
  /// Be null if no user logged.
  final LoggedUserInfo? loggedUserInfo;

  /// All pinned threads in groups.
  final List<PinnedThreadGroup> pinnedThreadGroupList;

  /// Swiper urls in the homepage.
  final List<SwiperUrl> swiperUrlList;

  /// The count of unread notices.
  final int unreadNoticeCount;

  /// Flag indicating has unread messages or not.
  final bool hasUnreadMessage;

  /// Copy with
  HomepageState copyWith({
    HomepageStatus? status,
    ForumStatus? forumStatus,
    LoggedUserInfo? loggedUserInfo,
    List<PinnedThreadGroup>? pinnedThreadGroupList,
    List<SwiperUrl>? swiperUrlList,
    int? documentHashCode,
    int? unreadNoticeCount,
    bool? hasUnreadMessage,
  }) {
    return HomepageState(
      status: status ?? this.status,
      forumStatus: forumStatus ?? this.forumStatus,
      loggedUserInfo: loggedUserInfo ?? this.loggedUserInfo,
      pinnedThreadGroupList:
          pinnedThreadGroupList ?? this.pinnedThreadGroupList,
      swiperUrlList: swiperUrlList ?? this.swiperUrlList,
      unreadNoticeCount: unreadNoticeCount ?? this.unreadNoticeCount,
      hasUnreadMessage: hasUnreadMessage ?? this.hasUnreadMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        forumStatus,
        loggedUserInfo,
        pinnedThreadGroupList,
        swiperUrlList,
        unreadNoticeCount,
      ];
}
