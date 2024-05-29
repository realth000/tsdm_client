import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/authentication/repository/exceptions/exceptions.dart';
import 'package:tsdm_client/features/profile/models/models.dart';
import 'package:tsdm_client/shared/repositories/profile_repository/profile_repository.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

part '../../../../generated/features/profile/bloc/profile_bloc.mapper.dart';
part 'profile_event.dart';
part 'profile_state.dart';

/// Emitter
typedef ProfileEmitter = Emitter<ProfileState>;

/// Bloc of user profile page.
///
/// This profile page is for current logged user.
///
/// Actually other user's profile page should have a similar bloc but
/// without [ProfileStatus.needLogin] status.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  /// Constructor.
  ProfileBloc({
    required ProfileRepository profileRepository,
    required AuthenticationRepository authenticationRepository,
  })  : _profileRepository = profileRepository,
        _authenticationRepository = authenticationRepository,
        super(const ProfileState()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
    on<ProfileLogoutRequested>(_onProfileLogoutRequested);
  }

  final ProfileRepository _profileRepository;
  final AuthenticationRepository _authenticationRepository;

  final RegExp _birthdayRe =
      RegExp(r'((?<y>\d+) 年)? ?((?<m>\d+) 月)? ?((?<d>\d+) 日)?');

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    ProfileEmitter emit,
  ) async {
    if (event.username == null &&
        event.uid == null &&
        _profileRepository.hasCache()) {
      final userProfile = _buildProfile(_profileRepository.getCache()!);
      final (unreadNoticeCount, hasUnreadMessage) =
          _buildUnreadInfoStatus(_profileRepository.getCache()!);
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          userProfile: userProfile,
          unreadNoticeCount: unreadNoticeCount,
          hasUnreadMessage: hasUnreadMessage,
        ),
      );
      return;
    }
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      final document = await _profileRepository.fetchProfile(
        username: event.username,
        uid: event.uid,
      );
      if (document == null) {
        emit(state.copyWith(status: ProfileStatus.needLogin));
        return;
      }
      final userProfile = _buildProfile(document);
      if (userProfile == null) {
        debug('failed to parse user profile');
        emit(state.copyWith(status: ProfileStatus.failed));
        return;
      }
      final (unreadNoticeCount, hasUnreadMessage) =
          _buildUnreadInfoStatus(document);
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          userProfile: userProfile,
          unreadNoticeCount: unreadNoticeCount,
          hasUnreadMessage: hasUnreadMessage,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      debug('failed to load profile: $e');
      emit(state.copyWith(status: ProfileStatus.failed));
    }
  }

  Future<void> _onProfileRefreshRequested(
    ProfileRefreshRequested event,
    ProfileEmitter emit,
  ) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      final document = await _profileRepository.fetchProfile(force: true);
      if (document == null) {
        emit(state.copyWith(status: ProfileStatus.needLogin));
        return;
      }
      final userProfile = _buildProfile(document);
      if (userProfile == null) {
        debug('failed to parse user profile');
        emit(state.copyWith(status: ProfileStatus.failed));
        return;
      }
      final (unreadNoticeCount, hasUnreadMessage) =
          _buildUnreadInfoStatus(document);
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          userProfile: userProfile,
          unreadNoticeCount: unreadNoticeCount,
          hasUnreadMessage: hasUnreadMessage,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      debug('failed to refresh profile: $e');
      emit(state.copyWith(status: ProfileStatus.failed));
      return;
    }
  }

  Future<void> _onProfileLogoutRequested(
    ProfileLogoutRequested event,
    ProfileEmitter emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.logout));
    try {
      await _authenticationRepository.logout();
      _profileRepository.logout();
      emit(state.copyWith(status: ProfileStatus.needLogin));
    } on HttpRequestFailedException catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          failedToLogoutReason: e,
        ),
      );
    } on LogoutException catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          failedToLogoutReason: e,
        ),
      );
    }
  }

  /// Build a user profile [UserProfile] from given html [document].
  UserProfile? _buildProfile(uh.Document document) {
    final profileRootNode = document.querySelector('div#pprl > div.bm.bbda');

    if (profileRootNode == null) {
      return null;
    }

    final avatarUrl = document
        .querySelector('div#wp.wp div#ct.ct2 div.sd div.hm > p > a > img')
        ?.imageUrl();

    // Basic info
    final username = profileRootNode
        .querySelector('h2.mbn')
        ?.nodes
        .firstOrNull
        ?.text
        ?.trim();
    final uid = profileRootNode
        .querySelector('h2.mbn > span.xw0')
        ?.text
        ?.split(': ')
        .lastOrNull
        ?.split(')')
        .firstOrNull;

    ///////////  Basic status ///////////

    bool? emailVerified;
    bool? videoVerified;
    String? customTitle;
    String? signature;
    String? friendsCount;

    ///////////  Some other basic status ///////////

    String? birthdayYear;
    String? birthdayMonth;
    String? birthdayDay;
    String? zodiac;
    String? msn;
    String? introduction;
    String? nickname;
    String? gender;
    String? from;
    String? qq;

    final basicInfoList = profileRootNode
        .querySelectorAll('div.pbm:nth-child(1) li')
        .map((e) => e.parseLiEmNode())
        .whereType<(String, String)>();

    for (final attr in basicInfoList) {
      switch (attr.$1) {
        case '邮箱状态':
          emailVerified = attr.$2 == '已验证';
        case '视频认证':
          videoVerified = attr.$2 == '已验证';
        case '自定义头衔':
          customTitle = attr.$2;
        case '个人签名':
          signature = attr.$2;
        case '统计信息':
          // Expect to have html fragment.
          friendsCount = attr.$2;
        case '生日':
          {
            final match = _birthdayRe.firstMatch(attr.$2);
            if (match != null) {
              birthdayYear = match.namedGroup('y');
              birthdayMonth = match.namedGroup('m');
              birthdayDay = match.namedGroup('d');
            }
          }

        case '星座':
          zodiac = attr.$2;
        case 'MSN':
          msn = attr.$2;
        case '自我介绍':
          introduction = attr.$2;
        case '昵称':
          nickname = attr.$2;
        case '性别':
          gender = attr.$2;
        case '来自':
          from = attr.$2;
        case 'QQ':
          qq = attr.$2;
      }
    }

    // Check in status
    final checkinNode = profileRootNode.querySelector('div.pbm.mbm.bbda.c');
    final checkinDaysCount = checkinNode
        ?.querySelector('p:nth-child(2)')
        ?.firstEndDeepText()
        ?.parseToInt();
    final checkinThisMonthCount =
        checkinNode?.querySelector('p:nth-child(3)')?.firstEndDeepText();
    final checkinRecentTime =
        checkinNode?.querySelector('p:nth-child(4)')?.firstEndDeepText();
    final checkinAllCoins = checkinNode
        ?.querySelector('p:nth-child(5) font:nth-child(1)')
        ?.firstEndDeepText();
    final checkinLastTimeCoin = checkinNode
        ?.querySelector('p:nth-child(5) font:nth-child(2)')
        ?.firstEndDeepText();
    final checkinLevel = checkinNode
        ?.querySelector('p:nth-child(6) font:nth-child(1)')
        ?.firstEndDeepText();
    final checkinNextLevel = checkinNode
        ?.querySelector('p:nth-child(6) font:nth-child(2)')
        ?.firstEndDeepText();
    final checkinNextLevelDays = checkinNode
        ?.querySelector('p:nth-child(6) font:nth-child(3)')
        ?.firstEndDeepText()
        ?.parseToInt();
    final checkinTodayStatus =
        checkinNode?.querySelector('p:nth-child(7)')?.firstEndDeepText();

    ///////////  User group status ///////////

    String? moderatorGroup;
    String? userGroup;

    final userGroupInfoList = profileRootNode
        .querySelector('ul#pbbs')
        ?.previousElementSibling
        ?.querySelectorAll('li')
        .map((e) => e.parseLiEmNode())
        .whereType<(String, String)>();
    if (userGroupInfoList != null) {
      for (final info in userGroupInfoList) {
        switch (info.$1) {
          case '用户组':
            userGroup = info.$2;
          case '管理组':
            moderatorGroup = info.$2;
        }
      }
    }

    ///////////  Activity status ///////////

    String? onlineTime;
    DateTime? registerTime;
    DateTime? lastVisitTime;
    DateTime? lastActiveTime;
    String? registerIP;
    String? lastVisitIP;
    DateTime? lastPostTime;
    String? timezone;

    // Activity overview
    // TODO: Parse manager groups and user groups belonged to, here.
    final activityNode = profileRootNode.querySelector('ul#pbbs');
    final activityInfoList = activityNode
            ?.querySelectorAll('li')
            .map((e) => e.parseLiEmNode())
            .whereType<(String, String)>()
            .toList() ??
        [];

    for (final info in activityInfoList) {
      switch (info.$1) {
        case '在线时间':
          onlineTime = info.$2;
        case '注册时间':
          registerTime = info.$2.parseToDateTimeUtc8();
        case '最后访问':
          lastVisitTime = info.$2.parseToDateTimeUtc8();
        case '上次活动时间':
          lastActiveTime = info.$2.parseToDateTimeUtc8();
        case '上次发表时间':
          lastPostTime = info.$2.parseToDateTimeUtc8();
        case '所在时区':
          timezone = info.$2;
        case '注册 IP': // Privacy info
          registerIP = info.$2;
        case '上次访问 IP': // Privacy info
          lastVisitIP = info.$2;
      }
    }

    ///////////  Statistics status ///////////
    String? credits;
    String? famous;
    String? coins;
    String? publicity;
    String? natural;
    String? scheming;
    String? spirit;
    String? seal;

    final statisticsInfoList = profileRootNode
        .querySelectorAll('div#psts > ul > li')
        .map((e) => e.parseLiEmNode())
        .whereType<(String, String)>();
    for (final stat in statisticsInfoList) {
      switch (stat.$1) {
        case '积分':
          credits = stat.$2;
        case '威望':
          famous = stat.$2;
        case '天使币':
          coins = stat.$2;
        case '宣传':
          publicity = stat.$2;
        case '天然':
          natural = stat.$2;
        case '腹黑':
          scheming = stat.$2;
        case '精灵':
          spirit = stat.$2;
        case '龙之印章':
          seal = stat.$2;
      }
    }

    return UserProfile(
      avatarUrl: avatarUrl,
      username: username,
      uid: uid,

      ///////////  Basic status ///////////
      emailVerified: emailVerified,
      videoVerified: videoVerified,
      customTitle: customTitle,
      signature: signature,
      friendsCount: friendsCount,
      birthdayYear: birthdayYear,
      birthdayMonth: birthdayMonth,
      birthdayDay: birthdayDay,
      zodiac: zodiac,
      msn: msn,
      introduction: introduction,
      nickname: nickname,
      gender: gender,
      from: from,
      qq: qq,

      ///////////  Checkin status ///////////
      checkinDaysCount: checkinDaysCount == 0 ? null : checkinDaysCount,
      checkinThisMonthCount: checkinThisMonthCount,
      checkinRecentTime: checkinRecentTime,
      checkinAllCoins: checkinAllCoins,
      checkinLastTimeCoin: checkinLastTimeCoin,
      checkinLevel: checkinLevel,
      checkinNextLevel: checkinNextLevel,
      checkinNextLevelDays:
          checkinNextLevelDays == 0 ? null : checkinNextLevelDays,
      checkinTodayStatus: checkinTodayStatus,

      ///////////  User group status ///////////
      moderatorGroup: moderatorGroup,
      userGroup: userGroup,

      ///////////  Activity status ///////////
      onlineTime: onlineTime,
      registerTime: registerTime,
      lastVisitTime: lastVisitTime,
      lastActiveTime: lastActiveTime,
      registerIP: registerIP,
      lastVisitIP: lastVisitIP,
      lastPostTime: lastPostTime,
      timezone: timezone,

      ///////////  Statistics status ///////////
      credits: credits,
      famous: famous,
      coins: coins,
      publicity: publicity,
      natural: natural,
      scheming: scheming,
      spirit: spirit,
      seal: seal,
    );
  }

  (int unreadNoticeCount, bool hasUnreadMessage) _buildUnreadInfoStatus(
    uh.Document document,
  ) {
    // Check notice status.
    var hasUnreadNotice = 0;
    final noticeNode = document.querySelector('a#myprompt');
    if (noticeNode?.classes.contains('new') ?? false) {
      hasUnreadNotice = noticeNode?.innerText
              .split('(')
              .lastOrNull
              ?.split(')')
              .firstOrNull
              ?.parseToInt() ??
          0;
    }

    final hasUnreadMessage =
        document.querySelector('a#pm_ntc')?.classes.contains('new') ?? false;

    return (hasUnreadNotice, hasUnreadMessage);
  }
}
