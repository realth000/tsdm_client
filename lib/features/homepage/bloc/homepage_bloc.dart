import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/authentication/repository/models/models.dart';
import 'package:tsdm_client/features/homepage/models/models.dart';
import 'package:tsdm_client/features/profile/repository/profile_repository.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;

part 'homepage_bloc.mapper.dart';
part 'homepage_event.dart';
part 'homepage_state.dart';

/// Extension on [uh.Document] to extract user info.
extension ExtractProfileAvatar on uh.Document {
  /// Extract the user avatar url.
  String? extractAvatar() {
    return querySelector('div#wp.wp div#ct.ct2 div.sd div.hm > p > a > img')?.imageUrl();
  }
}

/// Bloc for the homepage of the app.
class HomepageBloc extends Bloc<HomepageEvent, HomepageState> with LoggerMixin {
  /// Constructor.
  HomepageBloc({
    required ForumHomeRepository forumHomeRepository,
    required ProfileRepository profileRepository,
    required AuthenticationRepository authenticationRepository,
  }) : _forumHomeRepository = forumHomeRepository,
       _profileRepository = profileRepository,
       _authenticationRepository = authenticationRepository,
       super(
         forumHomeRepository.hasCache()
             ? _parseStateFromDocument(
               forumHomeRepository.getCache()!,
               authenticationRepository.currentUser?.username,
               avatarUrl: profileRepository.getCache()?.extractAvatar(),
             )
             : const HomepageState(),
       ) {
    on<HomepageLoadRequested>(_onHomepageLoadRequested);
    on<HomepageRefreshRequested>(_onHomepageRefreshRequested);
    on<HomepageAuthChanged>(_onHomepageAuthChanged);
    on<HomepagePauseSwiper>(_onHomepagePauseSwiper);
    on<HomepageResumeSwiper>(_onHomepageResumeSwiper);

    // Pair wise the latest two auth status so that we can check if only its
    // inner data changed. For example switch user from one to anther keeps an
    // authed state but the user is changed.
    _authStatusSub = _authenticationRepository.status.pairwise().listen(
      (statusList) =>
          add(HomepageAuthChanged(prev: statusList.elementAtOrNull(statusList.length - 2), curr: statusList.last)),
    );
  }

  final ForumHomeRepository _forumHomeRepository;
  final ProfileRepository _profileRepository;

  /// Do not dispose this repo because it is not the owner.
  final AuthenticationRepository _authenticationRepository;
  late final StreamSubscription<List<AuthStatus>> _authStatusSub;

  static List<String?> _buildKahrpbaPicUrlList(uh.Element? styleNode) {
    if (styleNode == null) {
      talker.error('failed to build kahrpba picture url list: node is null');
      return [];
    }

    return styleNode
        .innerHtmlEx()
        .split('\n')
        .where((e) => e.startsWith('.Kahrpba_pic_') && !e.contains('ctrlbtn'))
        .map((e) => e.split('(').lastOrNull?.split(')').firstOrNull)
        .toList();
  }

  static List<String?> _buildKahrpbaPicHrefList(uh.Element? scriptNode) {
    if (scriptNode == null) {
      talker.error('failed to build kahrpba picture href list: node is null');
      return [];
    }

    return scriptNode
        .innerHtmlEx()
        .split('\n')
        .where((e) => e.contains("window.location='"))
        .map((e) => e.split("window.location='").lastOrNull?.split("'").firstOrNull?.replaceFirst('&amp;', '&'))
        .toList();
  }

  /// For the following structure, filter and combine thread and its author.
  ///
  /// <div class="Kahrpba_threads">
  ///   <a href="thread_url">
  ///     thread_title
  ///   </a>
  ///   <a href="author_url">
  ///     <em>author_name</em>
  ///   </a>
  ///
  /// Filter out thread_url, thread_title, author_url and author_name.
  ///
  /// Where [element] is <div class="Kahrpba_threads"> node.
  static PinnedThread? _filterThreadAndAuthors(uh.Element element) {
    final allNode = element.querySelectorAll('a').toList();
    // There should be two <a> in children.
    if (allNode.length != 2) {
      talker.info(
        'skip build thread author pair: '
        'node count is ${allNode.length}',
      );
      return null;
    }

    final threadUrl = allNode[0].attributes['href'];
    if (threadUrl == null) {
      talker.info('skip incomplete thread author pair: thread url not found');
      return null;
    }

    final threadTitle = allNode[0].firstEndDeepText();
    if (threadTitle == null) {
      talker.info('skip incomplete thread author pair: thread title not found');
      return null;
    }

    final authorUrl = allNode[1].attributes['href'];
    if (authorUrl == null) {
      talker.info('skip incomplete thread author pair: author url not found');
      return null;
    }

    final authorName = allNode[1].firstEndDeepText();
    if (authorName == null) {
      talker.info('skip incomplete thread author pair: author name not found');
      return null;
    }

    return PinnedThread(threadUrl: threadUrl, threadTitle: threadTitle, authorUrl: authorUrl, authorName: authorName);
  }

  Future<void> _onHomepageLoadRequested(HomepageLoadRequested event, Emitter<HomepageState> emit) async {
    if (_forumHomeRepository.hasCache()) {
      final s = _parseStateFromDocument(
        _forumHomeRepository.getCache()!,
        _authenticationRepository.currentUser?.username,
        avatarUrl: state.loggedUserInfo?.avatarUrl,
      );
      emit(s);
      return;
    }
    // Clear data.
    emit(const HomepageState(status: HomepageStatus.loading));
    var needLogin = false;
    final respList =
        (await Future.wait([
          _forumHomeRepository.fetchHomePage().mapLeft((e) {
            if (e case HttpHandshakeFailedException(:final statusCode)) {
              if (statusCode == 200) {
                needLogin = true;
              }
            } else if (e case LoginUserInfoNotFoundException()) {
              needLogin = true;
            } else {
              handle(e);
            }
          }).run(),
          _profileRepository.fetchAvatarUrl().mapLeft((e) {
            switch (e) {
              case LoginUserInfoNotFoundException() || ProfileNeedLoginException():
                needLogin = true;
              default:
                handle(e);
            }
          }).run(),
        ])).where((e) => e.isRight()).map((e) => e.unwrap()).toList();
    if (respList.length != 2) {
      if (_authenticationRepository.currentUser == null && needLogin) {
        emit(state.copyWith(status: HomepageStatus.needLogin));
        return;
      } else {
        emit(state.copyWith(status: HomepageStatus.failure));
        return;
      }
    }
    final document = respList[0] as uh.Document;
    final avatarUrl = respList[1] as String;
    await _authenticationRepository.loginWithDocument(document).mapLeft(handle).run();
    // Parse data and change state.
    final s = _parseStateFromDocument(document, _authenticationRepository.currentUser?.username, avatarUrl: avatarUrl);
    emit(s);
  }

  Future<void> _onHomepageRefreshRequested(HomepageRefreshRequested event, Emitter<HomepageState> emit) async {
    // Clear data.
    emit(const HomepageState(status: HomepageStatus.loading));

    switch (await _forumHomeRepository.fetchHomePage(force: true).run()) {
      case Left(:final value):
        handle(value);
        debug('failed to fetch dom: $value');
        emit(state.copyWith(status: HomepageStatus.failure));
      case Right(:final value):
        await _authenticationRepository
            .loginWithDocument(value)
            .mapLeft((e) {
              handle(e);
              emit(state.copyWith(status: HomepageStatus.failure));
            })
            .map((v) => v)
            .run();
        final loggedUser = _authenticationRepository.currentUser;
        if (loggedUser == null) {
          emit(const HomepageState(status: HomepageStatus.needLogin));
          return;
        }
        final d2 = await _profileRepository.fetchProfile(force: true).run();
        if (d2.isLeft()) {
          handle(d2.unwrapErr());
          emit(state.copyWith(status: HomepageStatus.failure));
          return;
        }
        final avatarUrl = d2.unwrap().querySelector('div#wp.wp div#ct.ct2 div.sd div.hm > p > a > img')?.imageUrl();
        // Parse data and change state.
        final s = _parseStateFromDocument(value, _authenticationRepository.currentUser?.username, avatarUrl: avatarUrl);
        emit(s);
    }
  }

  Future<void> _onHomepageAuthChanged(HomepageAuthChanged event, Emitter<HomepageState> emit) async {
    if (event.curr is AuthStatusNotAuthed &&
        state.status != HomepageStatus.loading &&
        state.status != HomepageStatus.needLogin) {
      emit(state.copyWith(status: HomepageStatus.needLogin));
      return;
    }
    if (event.curr is AuthStatusAuthed &&
        // Bloc state changes from not authed to authed.
        (state.status == HomepageStatus.needLogin ||
            state.status == HomepageStatus.failure ||
            // Still authed, now and then, but user changed.
            event.prev != event.curr)) {
      // FIXME: anti-pattern
      final settings = getIt.get<SettingsRepository>().currentSettings;
      add(
        HomepageRefreshRequested(
          userLoginInfo: UserLoginInfo(username: settings.loginUsername, uid: settings.loginUid),
        ),
      );
    }
  }

  Future<void> _onHomepagePauseSwiper(HomepagePauseSwiper event, Emitter<HomepageState> emit) async {
    emit(state.copyWith(scrollSwiper: false));
  }

  Future<void> _onHomepageResumeSwiper(HomepageResumeSwiper event, Emitter<HomepageState> emit) async {
    emit(state.copyWith(scrollSwiper: true));
  }

  static HomepageState _parseStateFromDocument(uh.Document document, String? username, {String? avatarUrl}) {
    final swiperUrlList = <SwiperUrl>[];
    final pinnedThreadGroupList = <PinnedThreadGroup>[];
    ForumStatus? forumStatus;
    LoggedUserInfo? loggedUserInfo;

    final chartZNode = document.querySelector('p.chart.z');
    // TODO: Refactor with style repository here.
    final styleNode =
        // Style 1: Without welcome text.
        document.querySelector('div.mn > style') ??
        // Style 2: With welcome text.
        document.querySelector('div#chart > style');
    final scriptNode =
        // Style 1: Without welcome text.
        document.querySelector('div.mn > script') ??
        // Style 2: With welcome text
        document.querySelector('div#chart > script');

    final picUrlList = _buildKahrpbaPicUrlList(styleNode).whereType<String>().toList();
    final picHrefList = _buildKahrpbaPicHrefList(scriptNode).whereType<String>().toList();
    if ((picUrlList.isEmpty && picHrefList.isEmpty) || (picUrlList.length != picHrefList.length)) {
      talker.error('root content pinned pic not found: maybe not login');
      // There's no pinned recent threads when not login, just return
    } else {
      for (var i = 0; i < picUrlList.length; i++) {
        swiperUrlList.add(SwiperUrl(coverUrl: picUrlList[i], linkUrl: picHrefList[i]));
      }
    }
    final chartZInfoList = chartZNode?.querySelectorAll('em').toList();
    final memberInfoList = chartZInfoList?.map((e) => e.text).whereType<String>().toList(growable: false) ?? [];
    if (memberInfoList.length >= 3) {
      forumStatus = ForumStatus(
        todayCount: memberInfoList[0],
        yesterdayCount: memberInfoList[1],
        threadCount: memberInfoList[2],
      );
    }

    final welcomeNode = document.querySelector('div#wp.wp div#ct.wp.cl div#chart.bm.bw0.cl div.y');
    final loggedUsername = username ?? '';
    final loggedUserAvatar =
        avatarUrl ?? document.querySelector('div#hd div.wp div.hdc.cl div#um div.avt.y a img')?.attributes['src'];
    final navigateHrefsPairs =
        welcomeNode
            ?.querySelectorAll('a')
            .where((e) => e.attributes.containsKey('href'))
            .map((e) => (e.firstEndDeepText() ?? 'unknown', e.attributes['href']!))
            .toList();
    loggedUserInfo = LoggedUserInfo(
      username: loggedUsername,
      relatedLinkPairList: navigateHrefsPairs ?? [],
      avatarUrl: loggedUserAvatar,
    );

    final navNameList =
        document
            .querySelector('td#Kahrpba_nav')
            ?.children
            .map((e) => e.firstEndDeepText())
            .whereType<String>()
            .toList();
    final navShowList =
        document
            .querySelector('td#Kahrpba_show')
            ?.children
            .where((e) => e.id.startsWith('Kahrpba_c'))
            .whereType<uh.Element>()
            .toList();

    if (navNameList != null && navShowList != null && navNameList.length == navShowList.length) {
      if (navNameList.length >= 7) {
        navNameList
          ..swap(4, 6)
          ..swap(5, 6);
      }
      final count = navNameList.length;
      for (var i = 0; i < count; i++) {
        final threadList =
            navShowList[i]
                .querySelectorAll('div.Kahrpba_threads')
                .map(_filterThreadAndAuthors)
                .whereType<PinnedThread>()
                .toList();
        final group = PinnedThreadGroup(title: navNameList[i], threadList: threadList);
        pinnedThreadGroupList.add(group);
      }

      // The sort on server side is not as displayed, fix the sort to keep the
      // same with website appearance.
      if (pinnedThreadGroupList.length >= 7) {
        pinnedThreadGroupList
          ..swap(4, 5)
          ..swap(5, 6);
      }
    }
    return HomepageState(
      status: loggedUsername.isNotEmpty ? HomepageStatus.success : HomepageStatus.needLogin,
      forumStatus: forumStatus ?? const ForumStatus.empty(),
      loggedUserInfo: loggedUserInfo,
      pinnedThreadGroupList: pinnedThreadGroupList,
      swiperUrlList: swiperUrlList,
    );
  }

  @override
  Future<void> close() async {
    await _authStatusSub.cancel();
    await super.close();
  }
}
