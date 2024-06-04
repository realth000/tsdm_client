import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/authentication/view/login_page.dart';
import 'package:tsdm_client/features/chat/view/chat_history_page.dart';
import 'package:tsdm_client/features/chat/view/chat_page.dart';
import 'package:tsdm_client/features/forum/view/forum_page.dart';
import 'package:tsdm_client/features/home/view/home_page.dart';
import 'package:tsdm_client/features/homepage/view/homepage_page.dart';
import 'package:tsdm_client/features/image/view/image_detail_page.dart';
import 'package:tsdm_client/features/latest_thread/view/latest_thread_page.dart';
import 'package:tsdm_client/features/my_thread/view/my_thread_page.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/notification/view/broadcast_message_detail_page.dart';
import 'package:tsdm_client/features/notification/view/notification_detail_page.dart';
import 'package:tsdm_client/features/notification/view/notification_page.dart';
import 'package:tsdm_client/features/points/views/points_page.dart';
import 'package:tsdm_client/features/post/models/post_edit_type.dart';
import 'package:tsdm_client/features/post/view/post_edit_page.dart';
import 'package:tsdm_client/features/profile/view/profile_page.dart';
import 'package:tsdm_client/features/rate/view/rate_post_page.dart';
import 'package:tsdm_client/features/search/view/search_page.dart';
import 'package:tsdm_client/features/settings/view/about_page.dart';
import 'package:tsdm_client/features/settings/view/settings_page.dart';
import 'package:tsdm_client/features/settings/widgets/app_license_page.dart';
import 'package:tsdm_client/features/thread/view/thread_page.dart';
import 'package:tsdm_client/features/topics/view/topics_page.dart';
import 'package:tsdm_client/features/upgrade/view/upgrade_page.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';

final _rootRouteKey = GlobalKey<NavigatorState>();

/// App router instance.
final router = GoRouter(
  navigatorKey: _rootRouteKey,
  initialLocation: ScreenPaths.homepage,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, router, navigator) => HomePage(
        forumHomeRepository:
            RepositoryProvider.of<ForumHomeRepository>(context),
        showNavigationBar: true,
        child: navigator,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            AppRoute(
              path: ScreenPaths.homepage,
              builder: (_) => const HomepagePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            AppRoute(
              path: ScreenPaths.topic,
              builder: (_) => const TopicsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            AppRoute(
              path: ScreenPaths.settings,
              builder: (_) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    AppRoute(
      path: ScreenPaths.loggedUserProfile,
      builder: (_) => const ProfilePage(),
    ),
    AppRoute(
      path: ScreenPaths.about,
      parentNavigatorKey: _rootRouteKey,
      builder: (_) => const AboutPage(),
    ),
    AppRoute(
      path: ScreenPaths.license,
      parentNavigatorKey: _rootRouteKey,
      builder: (_) => const AppLicensePage(),
    ),
    AppRoute(
      path: ScreenPaths.upgrade,
      parentNavigatorKey: _rootRouteKey,
      builder: (_) => const UpgradePage(),
    ),
    AppRoute(
      path: ScreenPaths.forum,
      parentNavigatorKey: _rootRouteKey,
      builder: (state) {
        final title = state.uri.queryParameters['appBarTitle'];
        return ForumPage(
          title: title,
          fid: state.pathParameters['fid']!,
        );
      },
    ),
    AppRoute(
      path: ScreenPaths.thread,
      parentNavigatorKey: _rootRouteKey,
      builder: (state) {
        final title = state.uri.queryParameters['appBarTitle'];
        final threadType = state.uri.queryParameters['threadType'];
        final tid = state.uri.queryParameters['tid'];
        final pid = state.uri.queryParameters['pid'];
        assert(
          tid != null || pid != null,
          'MUST provide tid or pid through query parameters',
        );
        final pageNumber = state.uri.queryParameters['pageNumber'];
        return ThreadPage(
          title: title,
          threadType: threadType,
          threadID: tid,
          findPostID: pid,
          pageNumber: pageNumber ?? '1',
        );
      },
    ),
    AppRoute(
      path: ScreenPaths.search,
      parentNavigatorKey: _rootRouteKey,
      builder: (state) {
        final keyword = state.uri.queryParameters['keyword'];
        final authorUid = state.uri.queryParameters['authorUid'];
        final fid = state.uri.queryParameters['fid'];
        final page = state.uri.queryParameters['page'];
        return SearchPage(
          keyword: keyword,
          authorUid: authorUid,
          fid: fid,
          page: page,
        );
      },
    ),
    AppRoute(
      path: ScreenPaths.notice,
      parentNavigatorKey: _rootRouteKey,
      builder: (_) => const NotificationPage(),
    ),
    AppRoute(
      path: ScreenPaths.reply,
      parentNavigatorKey: _rootRouteKey,
      builder: (state) {
        final target = state.pathParameters['target']!;
        final noticeTypeIndex =
            state.uri.queryParameters['noticeType']!.parseToInt()!;
        return NoticeDetailPage(
          url: target,
          noticeType: NoticeType.values[noticeTypeIndex],
        );
      },
    ),
    AppRoute(
      path: ScreenPaths.myThread,
      parentNavigatorKey: _rootRouteKey,
      builder: (_) => const MyThreadPage(),
    ),
    AppRoute(
      path: ScreenPaths.latestThread,
      parentNavigatorKey: _rootRouteKey,
      builder: (state) {
        final url = state.uri.queryParameters['url']!;
        return LatestThreadPage(url: url);
      },
    ),
    AppRoute(
      path: ScreenPaths.login,
      parentNavigatorKey: _rootRouteKey,
      builder: (state) {
        if (state.extra == null) {
          return const LoginPage();
        }
        final loginArgsMap = state.extra! as Map<String, dynamic>;
        final redirectBackState =
            loginArgsMap['redirectBackState'] as GoRouterState;
        return LoginPage(redirectBackState: redirectBackState);
      },
    ),
    AppRoute(
      path: ScreenPaths.profile,
      parentNavigatorKey: _rootRouteKey,
      builder: (state) {
        final uid = state.uri.queryParameters['uid'];
        final username = state.uri.queryParameters['username'];
        // Fill uid and username to access user profile page.
        // Actually each one of them is enough to locate the user space url.
        // When both are provided, use uid in advance.
        return ProfilePage(uid: uid, username: username);
      },
    ),
    AppRoute(
      path: ScreenPaths.ratePost,
      parentNavigatorKey: _rootRouteKey,
      builder: (state) {
        final username = state.pathParameters['username']!;
        final pid = state.pathParameters['pid']!;
        final floor = state.pathParameters['floor']!;
        final rateAction = state.pathParameters['rateAction']!;
        return RatePostPage(
          username: username,
          pid: pid,
          floor: floor,
          rateAction: rateAction,
        );
      },
    ),
    AppRoute(
      path: ScreenPaths.points,
      parentNavigatorKey: _rootRouteKey,
      builder: (_) => const PointsPage(),
    ),
    AppRoute(
      path: ScreenPaths.editPost,
      parentNavigatorKey: _rootRouteKey,
      builder: (state) {
        final editType = state.pathParameters['editType']?.parseToInt();
        final fid = state.pathParameters['fid']!;
        final tid = state.pathParameters['tid']!;
        final pid = state.pathParameters['pid']!;
        assert(
          editType != null,
          'PostEditType enum value is not a integer: $editType',
        );
        assert(
          PostEditType.values.length > editType!,
          'invalid PostEditType enum value: $editType',
        );
        return PostEditPage(
          editType: PostEditType.values[editType!],
          fid: fid,
          tid: tid,
          pid: pid,
        );
      },
    ),
    AppRoute(
      path: ScreenPaths.broadcastMessageDetail,
      parentNavigatorKey: _rootRouteKey,
      builder: (state) {
        final pmid = state.pathParameters['pmid']!;
        return BroadcastMessageDetailPage(
          pmid: pmid,
        );
      },
    ),
    AppRoute(
      path: ScreenPaths.chat,
      parentNavigatorKey: _rootRouteKey,
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
      parentNavigatorKey: _rootRouteKey,
      builder: (state) {
        final uid = state.pathParameters['uid']!;
        return ChatHistoryPage(uid: uid);
      },
    ),
    AppRoute(
      path: ScreenPaths.imageDetail,
      parentNavigatorKey: _rootRouteKey,
      builder: (state) {
        final imageUrl = state.pathParameters['imageUrl']!;
        return ImageDetailPage(imageUrl);
      },
    ),
  ],
);

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
          pageBuilder: (context, state) => MaterialPage<void>(
            name: path,
            arguments: state.pathParameters,
            child: builder(state),
          ),
        );
}
