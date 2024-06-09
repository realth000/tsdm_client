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
  failure;

  /// Is [initial]?
  bool get isInitial => this == HomepageStatus.initial;

  /// Is [needLogin]?
  bool get isNeedLogin => this == HomepageStatus.needLogin;

  /// Is [loading]?
  bool get isLoading => this == HomepageStatus.loading;

  /// Is [success]?
  bool get isSuccess => this == HomepageStatus.success;

  /// Is [failure]?
  bool get isFailed => this == HomepageStatus.failure;
}

/// State of homepage.
@MappableClass()
final class HomepageState with HomepageStateMappable {
  /// Constructor.
  const HomepageState({
    this.status = HomepageStatus.initial,
    this.forumStatus = const ForumStatus.empty(),
    this.loggedUserInfo,
    this.pinnedThreadGroupList = const [],
    this.swiperUrlList = const [],
    this.unreadNoticeCount = 0,
    this.hasUnreadMessage = false,
    this.scrollSwiper = true,
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

  /// Flag indicating should let swiper scrolls or not.
  ///
  /// Should only scroll when current screen is home tab.
  final bool scrollSwiper;
}
