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

part '../../../generated/features/profile/bloc/profile_bloc.mapper.dart';
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
    final basicInfoList = profileRootNode
        .querySelectorAll('div.pbm:nth-child(1) li')
        .map((e) => e.parseLiEmNode())
        .whereType<(String, String)>()
        .toList();

    // Check in status
    final checkinNode = profileRootNode.querySelector('div.pbm.mbm.bbda.c');
    final checkinDaysCount =
        checkinNode?.querySelector('p:nth-child(2)')?.firstEndDeepText();
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
        ?.querySelector('p:nth-child(6) font:nth-child(3)')
        ?.firstEndDeepText();
    final checkinNextLevelDays = checkinNode
        ?.querySelector('p:nth-child(6) font:nth-child(5)')
        ?.firstEndDeepText();
    final checkinTodayStatus =
        checkinNode?.querySelector('p:nth-child(7)')?.firstEndDeepText();

    // Activity overview
    // TODO: Parse manager groups and user groups belonged to, here.
    final activityNode = profileRootNode.querySelector('ul#pbbs');
    final activityInfoList = activityNode
            ?.querySelectorAll('li')
            .map((e) => e.parseLiEmNode())
            .whereType<(String, String)>()
            .toList() ??
        [];

    return UserProfile(
      avatarUrl: avatarUrl,
      username: username,
      uid: uid,
      basicInfoList: basicInfoList,
      checkinDaysCount: checkinDaysCount,
      checkinThisMonthCount: checkinThisMonthCount,
      checkinRecentTime: checkinRecentTime,
      checkinAllCoins: checkinAllCoins,
      checkinLastTimeCoin: checkinLastTimeCoin,
      checkinLevel: checkinLevel,
      checkinNextLevel: checkinNextLevel,
      checkinNextLevelDays: checkinNextLevelDays,
      checkinTodayStatus: checkinTodayStatus,
      activityInfoList: activityInfoList,
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
