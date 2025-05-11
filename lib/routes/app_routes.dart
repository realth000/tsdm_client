import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/authentication/view/login_page.dart';
import 'package:tsdm_client/features/chat/view/chat_history_page.dart';
import 'package:tsdm_client/features/chat/view/chat_page.dart';
import 'package:tsdm_client/features/checkin/view/auto_checkin_page.dart';
import 'package:tsdm_client/features/forum/models/models.dart';
import 'package:tsdm_client/features/forum/view/forum_group_page.dart';
import 'package:tsdm_client/features/forum/view/forum_page.dart';
import 'package:tsdm_client/features/home/view/home_page.dart';
import 'package:tsdm_client/features/homepage/view/homepage_page.dart';
import 'package:tsdm_client/features/image/view/image_detail_page.dart';
import 'package:tsdm_client/features/latest_thread/view/latest_thread_page.dart';
import 'package:tsdm_client/features/multi_user/view/manage_account_page.dart';
import 'package:tsdm_client/features/my_thread/view/my_thread_page.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/notification/view/broadcast_message_detail_page.dart';
import 'package:tsdm_client/features/notification/view/notification_detail_page.dart';
import 'package:tsdm_client/features/notification/view/notification_page.dart';
import 'package:tsdm_client/features/notification/view/notification_search_page.dart';
import 'package:tsdm_client/features/packet/view/packet_detail_page.dart';
import 'package:tsdm_client/features/points/views/points_page.dart';
import 'package:tsdm_client/features/post/models/models.dart';
import 'package:tsdm_client/features/post/view/post_edit_page.dart';
import 'package:tsdm_client/features/profile/view/edit_avatar_page.dart';
import 'package:tsdm_client/features/profile/view/profile_page.dart';
import 'package:tsdm_client/features/profile/view/switch_user_group_page.dart';
import 'package:tsdm_client/features/rate/view/rate_post_page.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/features/root/view/singleton.dart';
import 'package:tsdm_client/features/search/view/search_page.dart';
import 'package:tsdm_client/features/settings/view/about_page.dart';
import 'package:tsdm_client/features/settings/view/debug_log_page.dart';
import 'package:tsdm_client/features/settings/view/settings_page.dart';
import 'package:tsdm_client/features/settings/view/thread_card_appearance.dart';
import 'package:tsdm_client/features/settings/widgets/app_license_page.dart';
import 'package:tsdm_client/features/thread/v1/view/thread_page.dart';
import 'package:tsdm_client/features/thread/v2/view/thread_page_v2.dart';
import 'package:tsdm_client/features/thread_visit_history/view/thread_visit_history_page.dart';
import 'package:tsdm_client/features/topics/view/topics_page.dart';
import 'package:tsdm_client/features/update/view/local_changelog_page.dart';
import 'package:tsdm_client/features/update/view/update_page.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';

/// App router instance wrapped with global singleton widgets.
final router = GoRouter(
  initialLocation: ScreenPaths.homepage,
  routes: [GoRoute(path: ScreenPaths.root, builder: (_, _) => const RootSingleton(), routes: _appRoutes)],
);

/// All named routes in app.
final _appRoutes = [
  StatefulShellRoute.indexedStack(
    builder: (context, router, navigator) {
      final hideNavigationBarPages = [ScreenPaths.settingsThreadAppearance.fullPath];
      return HomePage(
        forumHomeRepository: RepositoryProvider.of<ForumHomeRepository>(context),
        showNavigationBar: !hideNavigationBarPages.contains(router.fullPath),
        child: navigator,
      );
    },
    branches: [
      StatefulShellBranch(routes: [AppRoute(path: ScreenPaths.homepage, builder: (_) => const HomepagePage())]),
      StatefulShellBranch(routes: [AppRoute(path: ScreenPaths.topic, builder: (_) => const TopicsPage())]),
      StatefulShellBranch(
        routes: [
          AppRoute(
            path: ScreenPaths.settings.path,
            builder: (_) => const SettingsPage(),
            routes: [
              AppRoute(
                path: ScreenPaths.settingsThreadAppearance.path,
                builder: (_) => const SettingsThreadCardAppearancePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  AppRoute(
    path: ScreenPaths.loggedUserProfile,
    builder: (state) {
      final heroTag = state.uri.queryParameters['hero'];
      return ProfilePage(heroTag: heroTag);
    },
  ),
  AppRoute(path: ScreenPaths.about, builder: (_) => const AboutPage()),
  AppRoute(path: ScreenPaths.license, builder: (_) => const AppLicensePage()),
  AppRoute(
    path: ScreenPaths.forum,
    builder: (state) {
      final title = state.uri.queryParameters['appBarTitle'];
      final threadTypeName = state.uri.queryParameters['threadTypeName'];
      final threadTypeID = state.uri.queryParameters['threadTypeID'];
      final FilterType? threadType;
      if (threadTypeName != null && threadTypeID != null) {
        threadType = FilterType(name: threadTypeName, typeID: threadTypeID);
      } else {
        threadType = null;
      }
      return ForumPage(title: title, fid: state.pathParameters['fid']!, threadType: threadType);
    },
  ),
  AppRoute(
    path: ScreenPaths.forumGroup,
    builder: (state) {
      final gid = state.pathParameters['gid'];
      final title = state.uri.queryParameters['title'];

      return ForumGroupPage(gid: gid!, title: title);
    },
  ),
  AppRoute(
    path: ScreenPaths.threadV1,
    builder: (state) {
      final title = state.uri.queryParameters['appBarTitle'];
      final threadTypeName = state.uri.queryParameters['threadTypeName'];
      final threadTypeID = state.uri.queryParameters['threadTypeID'];
      final FilterType? threadType;
      if (threadTypeName != null && threadTypeID != null) {
        threadType = FilterType(name: threadTypeName, typeID: threadTypeID);
      } else {
        threadType = null;
      }

      final tid = state.uri.queryParameters['tid'];
      final pid = state.uri.queryParameters['pid'];
      final onlyVisibleUid = state.uri.queryParameters['onlyVisibleUid'];
      final bool overrideReverseOrder;
      if (state.uri.queryParameters['overrideReverseOrder'] == 'false') {
        overrideReverseOrder = false;
      } else {
        overrideReverseOrder = true;
      }
      final overrideWithExactOrder = state.uri.queryParameters['overrideWithExactOrder']?.parseToInt();

      assert(tid != null || pid != null, 'MUST provide tid or pid through query parameters');
      final pageNumber = state.uri.queryParameters['pageNumber'];
      return ThreadPage(
        title: title,
        threadType: threadType,
        threadID: tid,
        findPostID: pid,
        pageNumber: pageNumber ?? '1',
        overrideReverseOrder: overrideReverseOrder,
        overrideWithExactOrder: overrideWithExactOrder,
        onlyVisibleUid: onlyVisibleUid,
      );
    },
  ),
  AppRoute(
    path: ScreenPaths.threadV2,
    builder: (state) {
      final id = state.pathParameters['id']!;
      final bool overrideReverseOrder;
      final onlyVisibleUid = state.uri.queryParameters['onlyVisibleUid'];
      if (state.uri.queryParameters['overrideReverseOrder'] == 'false') {
        overrideReverseOrder = false;
      } else {
        overrideReverseOrder = true;
      }
      final overrideWithExactOrder = state.uri.queryParameters['overrideWithExactOrder']?.parseToInt();
      final pageNumber = state.uri.queryParameters['pageNumber'];
      final pid = state.uri.queryParameters['pid'];

      return ThreadPageV2(
        id: id,
        pageNumber: pageNumber ?? '1',
        overrideReverseOrder: overrideReverseOrder,
        overrideWithExactOrder: overrideWithExactOrder,
        onlyVisibleUid: onlyVisibleUid,
        pid: pid?.parseToInt(),
      );
    },
  ),
  AppRoute(
    path: ScreenPaths.search,
    builder: (state) {
      final keyword = state.uri.queryParameters['keyword'];
      final authorUid = state.uri.queryParameters['authorUid'];
      final fid = state.uri.queryParameters['fid'];
      final page = state.uri.queryParameters['page'];
      return SearchPage(keyword: keyword, authorUid: authorUid, fid: fid, page: page);
    },
  ),
  AppRoute(path: ScreenPaths.notice, builder: (_) => const NotificationPage()),
  AppRoute(
    path: ScreenPaths.reply,
    builder: (state) {
      final target = state.pathParameters['target']!;
      final noticeTypeIndex = state.uri.queryParameters['noticeType']!.parseToInt()!;
      return NoticeDetailPage(url: target, noticeType: NoticeType.values[noticeTypeIndex]);
    },
  ),
  AppRoute(path: ScreenPaths.noticeSearch, builder: (_) => const NotificationSearchPage()),
  AppRoute(path: ScreenPaths.myThread, builder: (_) => const MyThreadPage()),
  AppRoute(
    path: ScreenPaths.latestThread,
    builder: (state) {
      final url = state.uri.queryParameters['url']!;
      return LatestThreadPage(url: url);
    },
  ),
  AppRoute(
    path: ScreenPaths.login,
    builder: (state) {
      final username = state.uri.queryParameters['username'];
      if (state.extra == null) {
        return LoginPage(username: username);
      }
      final loginArgsMap = state.extra! as Map<String, dynamic>;
      final redirectBackState = loginArgsMap['redirectBackState'] as GoRouterState;
      return LoginPage(redirectBackState: redirectBackState, username: username);
    },
  ),
  AppRoute(
    path: ScreenPaths.profile,
    builder: (state) {
      final uid = state.uri.queryParameters['uid'];
      final username = state.uri.queryParameters['username'];
      final heroTag = state.uri.queryParameters['hero'];
      // Fill uid and username to access user profile page.
      // Actually each one of them is enough to locate the user space url.
      // When both are provided, use uid in advance.
      return ProfilePage(uid: uid, username: username, heroTag: heroTag);
    },
  ),
  AppRoute(path: ScreenPaths.editAvatar, builder: (_) => const EditAvatarPage()),
  AppRoute(path: ScreenPaths.switchUserGroup, builder: (_) => const SwitchUserGroupPage()),
  AppRoute(
    path: ScreenPaths.ratePost,
    builder: (state) {
      final username = state.pathParameters['username']!;
      final pid = state.pathParameters['pid']!;
      final floor = state.pathParameters['floor']!;
      final rateAction = state.pathParameters['rateAction']!;
      return RatePostPage(username: username, pid: pid, floor: floor, rateAction: rateAction);
    },
  ),
  AppRoute(path: ScreenPaths.points, builder: (_) => const PointsPage()),
  AppRoute(
    path: ScreenPaths.editPost,
    builder: (state) {
      final editType = state.pathParameters['editType']?.parseToInt();
      final fid = state.pathParameters['fid']!;
      final tid = state.uri.queryParameters['tid'];
      final pid = state.uri.queryParameters['pid'];
      assert(editType != null, 'PostEditType enum value is not a integer: $editType');
      assert(PostEditType.values.length > editType!, 'invalid PostEditType enum value: $editType');
      return PostEditPage(editType: PostEditType.values[editType!], fid: fid, tid: tid, pid: pid);
    },
  ),
  AppRoute(
    path: ScreenPaths.broadcastMessageDetail,
    builder: (state) {
      final pmid = state.pathParameters['pmid']!;
      return BroadcastMessageDetailPage(pmid: pmid);
    },
  ),
  AppRoute(
    path: ScreenPaths.chat,
    builder: (state) {
      final uid = state.pathParameters['uid']!;
      String? username;
      if (state.extra is Map<String, dynamic>) {
        final map = state.extra! as Map<String, dynamic>;
        username = map['username'] as String?;
      }
      return ChatPage(username: username, uid: uid);
    },
  ),
  AppRoute(
    path: ScreenPaths.chatHistory,
    builder: (state) {
      final uid = state.pathParameters['uid']!;
      return ChatHistoryPage(uid: uid);
    },
  ),
  AppRoute(
    path: ScreenPaths.imageDetail,
    builder: (state) {
      final imageUrl = state.pathParameters['imageUrl']!;
      return ImageDetailPage(imageUrl);
    },
  ),
  AppRoute(path: ScreenPaths.threadVisitHistory, builder: (_) => const ThreadVisitHistoryPage()),
  AppRoute(path: ScreenPaths.autoCheckinDetail, builder: (_) => const AutoCheckinPage()),
  AppRoute(path: ScreenPaths.debugLog, builder: (_) => const DebugLogPage()),
  AppRoute(
    path: ScreenPaths.packetDetail,
    builder: (state) {
      final tid = int.parse(state.pathParameters['tid']!);
      return PacketDetailPage(tid);
    },
  ),
  AppRoute(path: ScreenPaths.manageAccount, builder: (_) => const ManageAccountPage()),
  AppRoute(path: ScreenPaths.update, builder: (_) => const UpdatePage()),
  AppRoute(path: ScreenPaths.localChangelog, builder: (_) => const LocalChangelogPage()),
];

/// Refer from wondrous app.
/// Custom router declaration.
class AppRoute extends GoRoute {
  /// Constructor.
  AppRoute({
    required super.path,
    required Widget Function(GoRouterState s) builder,
    List<GoRoute> routes = const [],
    super.parentNavigatorKey,
    super.redirect,
  }) : super(
         name: path,
         routes: routes,
         pageBuilder:
             (context, state) =>
                 MaterialPage<void>(name: path, arguments: state.pathParameters, child: RootPage(path, builder(state))),
       );
}
