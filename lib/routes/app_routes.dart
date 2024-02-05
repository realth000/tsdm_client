import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/authentication/view/login_page.dart';
import 'package:tsdm_client/features/forum/view/forum_page.dart';
import 'package:tsdm_client/features/home/view/home_page.dart';
import 'package:tsdm_client/features/homepage/view/homepage_page.dart';
import 'package:tsdm_client/features/latest_thread/view/latest_thread_page.dart';
import 'package:tsdm_client/features/my_thread/view/my_thread_page.dart';
import 'package:tsdm_client/features/notification/models/notice.dart';
import 'package:tsdm_client/features/notification/view/notification_detail_page.dart';
import 'package:tsdm_client/features/notification/view/notification_page.dart';
import 'package:tsdm_client/features/points/views/points_page.dart';
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
final _shellRouteKey = GlobalKey<NavigatorState>();

/// App router instance.
final router = GoRouter(
  navigatorKey: _rootRouteKey,
  initialLocation: ScreenPaths.homepage,
  routes: [
    ShellRoute(
      navigatorKey: _shellRouteKey,
      builder: (context, router, navigator) => HomePage(
        forumHomeRepository:
            RepositoryProvider.of<ForumHomeRepository>(context),
        showNavigationBar: true,
        child: navigator,
      ),
      routes: [
        AppRoute(
          path: ScreenPaths.homepage,
          parentNavigatorKey: _shellRouteKey,
          builder: (_) => const HomepagePage(),
        ),
        AppRoute(
          path: ScreenPaths.topic,
          parentNavigatorKey: _shellRouteKey,
          builder: (_) => const TopicsPage(),
        ),
        AppRoute(
          path: ScreenPaths.loggedUserProfile,
          parentNavigatorKey: _shellRouteKey,
          builder: (_) => const ProfilePage(),
        ),
        AppRoute(
          path: ScreenPaths.settings,
          parentNavigatorKey: _shellRouteKey,
          builder: (_) => const SettingsPage(),
        ),
      ],
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
        final tid = state.pathParameters['tid']!;
        final pageNumber = state.uri.queryParameters['pageNumber'];
        return ThreadPage(
          title: title,
          threadType: threadType,
          threadID: tid,
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
