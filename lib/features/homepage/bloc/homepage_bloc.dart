import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/homepage/models/models.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/shared/repositories/profile_repository/profile_repository.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

part 'homepage_event.dart';
part 'homepage_state.dart';

/// Extension on [uh.Document] to extract user info.
extension ExtractProfileAvatar on uh.Document {
  /// Extract the user avatar url.
  String? extractAvatar() {
    return querySelector('div#wp.wp div#ct.ct2 div.sd div.hm > p > a > img')
        ?.imageUrl();
  }
}

/// Bloc for the homepage of the app.
class HomepageBloc extends Bloc<HomepageEvent, HomepageState> {
  /// Constructor.
  HomepageBloc({
    required ForumHomeRepository forumHomeRepository,
    required ProfileRepository profileRepository,
    required AuthenticationRepository authenticationRepository,
  })  : _forumHomeRepository = forumHomeRepository,
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
    on<_HomepageAuthChanged>(_onHomepageAuthChanged);

    _authStatusSub = _authenticationRepository.status.listen(
      (status) => add(
        _HomepageAuthChanged(
          isLogged: status == AuthenticationStatus.authenticated,
        ),
      ),
    );
  }

  final ForumHomeRepository _forumHomeRepository;
  final ProfileRepository _profileRepository;

  /// Do not dispose this repo because it is not the owner.
  final AuthenticationRepository _authenticationRepository;
  late final StreamSubscription<AuthenticationStatus> _authStatusSub;

  Future<void> _onHomepageLoadRequested(
    HomepageLoadRequested event,
    Emitter<HomepageState> emit,
  ) async {
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
    try {
      final documentList = (await Future.wait(
        [
          _forumHomeRepository.fetchHomePage(),
          _profileRepository.fetchProfile(),
        ],
      ))
          .whereType<uh.Document>()
          .toList();
      if (documentList.length != 2) {
        if (_authenticationRepository.currentUser == null) {
          emit(state.copyWith(status: HomepageStatus.needLogin));
          return;
        } else {
          emit(state.copyWith(status: HomepageStatus.failed));
          return;
        }
      }
      final document = documentList[0];
      final avatarUrl = documentList[1]
          .querySelector('div#wp.wp div#ct.ct2 div.sd div.hm > p > a > img')
          ?.imageUrl();
      await _authenticationRepository.loginWithDocument(document);
      // Parse data and change state.
      final s = _parseStateFromDocument(
        document,
        _authenticationRepository.currentUser?.username,
        avatarUrl: avatarUrl,
      );
      emit(s);
    } on HttpHandshakeFailedException catch (e) {
      debug('[HomepageBloc]: Failed to fetch home page: $e');
      emit(state.copyWith(status: HomepageStatus.failed));
      return;
    } on HttpRequestFailedException catch (e) {
      debug('[HomepageBloc]: Failed to fetch home page: $e');
      emit(state.copyWith(status: HomepageStatus.failed));
      return;
    }
  }

  Future<void> _onHomepageRefreshRequested(
    HomepageRefreshRequested event,
    Emitter<HomepageState> emit,
  ) async {
    try {
      // Clear data.
      emit(const HomepageState(status: HomepageStatus.loading));
      final document = await _forumHomeRepository.fetchHomePage(force: true);
      await _authenticationRepository.loginWithDocument(document);
      final loggedUser = _authenticationRepository.currentUser;
      if (loggedUser == null) {
        emit(const HomepageState(status: HomepageStatus.needLogin));
        return;
      }
      final d2 = await _profileRepository.fetchProfile(force: true);
      final avatarUrl = d2
          ?.querySelector('div#wp.wp div#ct.ct2 div.sd div.hm > p > a > img')
          ?.imageUrl();
      // Parse data and change state.
      final s = _parseStateFromDocument(
        document,
        _authenticationRepository.currentUser?.username,
        avatarUrl: avatarUrl,
      );
      emit(s);
    } on HttpHandshakeFailedException catch (e) {
      debug('failed to fetch dom: $e');
      rethrow;
    }
  }

  Future<void> _onHomepageAuthChanged(
    _HomepageAuthChanged event,
    Emitter<HomepageState> emit,
  ) async {
    if (event.isLogged) {
      emit(state.copyWith(status: HomepageStatus.success));
      return;
    }
    emit(state.copyWith(status: HomepageStatus.needLogin));
  }

  static HomepageState _parseStateFromDocument(
    uh.Document document,
    String? username, {
    String? avatarUrl,
  }) {
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

    final picUrlList =
        _buildKahrpbaPicUrlList(styleNode).whereType<String>().toList();
    final picHrefList =
        _buildKahrpbaPicHrefList(scriptNode).whereType<String>().toList();
    if ((picUrlList.isEmpty && picHrefList.isEmpty) ||
        (picUrlList.length != picHrefList.length)) {
      debug('root content pinned pic not found: maybe not login');
      // There's no pinned recent threads when not login, just return
    } else {
      for (var i = 0; i < picUrlList.length; i++) {
        swiperUrlList
            .add(SwiperUrl(coverUrl: picUrlList[i], linkUrl: picHrefList[i]));
      }
    }
    final chartZInfoList = chartZNode?.querySelectorAll('em').toList();
    final memberInfoList = chartZInfoList
            ?.map((e) => e.text)
            .whereType<String>()
            .toList(growable: false) ??
        [];
    if (memberInfoList.length >= 3) {
      forumStatus = ForumStatus(
        todayCount: memberInfoList[0],
        yesterdayCount: memberInfoList[1],
        threadCount: memberInfoList[2],
      );
    }

    final welcomeNode = document
        .querySelector('div#wp.wp div#ct.wp.cl div#chart.bm.bw0.cl div.y');
    final loggedUsername = username ?? '';
    final loggedUserAvatar = avatarUrl ??
        document
            .querySelector('div#hd div.wp div.hdc.cl div#um div.avt.y a img')
            ?.attributes['src'];
    final navigateHrefsPairs = welcomeNode
        ?.querySelectorAll('a')
        .where((e) => e.attributes.containsKey('href'))
        .map((e) => (e.firstEndDeepText() ?? 'unknown', e.attributes['href']!))
        .toList();
    loggedUserInfo = LoggedUserInfo(
      username: loggedUsername,
      relatedLinkPairList: navigateHrefsPairs ?? [],
      avatarUrl: loggedUserAvatar,
    );

    final navNameList = document
        .querySelector('td#Kahrpba_nav')
        ?.children
        .map((e) => e.firstEndDeepText())
        .whereType<String>()
        .toList();
    final navShowList = document
        .querySelector('td#Kahrpba_show')
        ?.children
        .where((e) => e.id.startsWith('Kahrpba_c'))
        .whereType<uh.Element>()
        .toList();

    if (navNameList != null &&
        navShowList != null &&
        navNameList.length == navShowList.length) {
      if (navNameList.length >= 7) {
        navNameList
          ..swap(4, 6)
          ..swap(5, 6);
      }
      final count = navNameList.length;
      for (var i = 0; i < count; i++) {
        final threadList = navShowList[i]
            .querySelectorAll('div.Kahrpba_threads')
            .map(_filterThreadAndAuthors)
            .whereType<PinnedThread>()
            .toList();
        final group = PinnedThreadGroup(
          title: navNameList[i],
          threadList: threadList,
        );
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
      status: loggedUsername.isNotEmpty
          ? HomepageStatus.success
          : HomepageStatus.needLogin,
      forumStatus: forumStatus ?? const ForumStatus.empty(),
      loggedUserInfo: loggedUserInfo,
      pinnedThreadGroupList: pinnedThreadGroupList,
      swiperUrlList: swiperUrlList,
      unreadNoticeCount: hasUnreadNotice,
      hasUnreadMessage: hasUnreadMessage,
    );
  }

  @override
  Future<void> close() async {
    await _authStatusSub.cancel();
    await super.close();
  }
}

List<String?> _buildKahrpbaPicUrlList(uh.Element? styleNode) {
  if (styleNode == null) {
    debug('failed to build kahrpba picture url list: node is null');
    return [];
  }

  return styleNode
      .innerHtmlEx()
      .split('\n')
      .where((e) => e.startsWith('.Kahrpba_pic_') && !e.contains('ctrlbtn'))
      .map((e) => e.split('(').lastOrNull?.split(')').firstOrNull)
      .toList();
}

List<String?> _buildKahrpbaPicHrefList(uh.Element? scriptNode) {
  if (scriptNode == null) {
    debug('failed to build kahrpba picture href list: node is null');
    return [];
  }

  return scriptNode
      .innerHtmlEx()
      .split('\n')
      .where((e) => e.contains("window.location='"))
      .map(
        (e) => e
            .split("window.location='")
            .lastOrNull
            ?.split("'")
            .firstOrNull
            ?.replaceFirst('&amp;', '&'),
      )
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
PinnedThread? _filterThreadAndAuthors(uh.Element element) {
  final allNode = element.querySelectorAll('a').toList();
  // There should be two <a> in children.
  if (allNode.length != 2) {
    debug('skip build thread author pair: node count is ${allNode.length}');
    return null;
  }

  final threadUrl = allNode[0].attributes['href'];
  if (threadUrl == null) {
    debug('skip incomplete thread author pair: thread url not found');
    return null;
  }

  final threadTitle = allNode[0].firstEndDeepText();
  if (threadTitle == null) {
    debug('skip incomplete thread author pair: thread title not found');
    return null;
  }

  final authorUrl = allNode[1].attributes['href'];
  if (authorUrl == null) {
    debug('skip incomplete thread author pair: author url not found');
    return null;
  }

  final authorName = allNode[1].firstEndDeepText();
  if (authorName == null) {
    debug('skip incomplete thread author pair: author name not found');
    return null;
  }

  return PinnedThread(
    threadUrl: threadUrl,
    threadTitle: threadTitle,
    authorUrl: authorUrl,
    authorName: authorName,
  );
}
