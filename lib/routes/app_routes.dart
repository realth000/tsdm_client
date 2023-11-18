import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/screens/forum/forum_page.dart';
import 'package:tsdm_client/screens/homepage/homepage.dart';
import 'package:tsdm_client/screens/login/login_page.dart';
import 'package:tsdm_client/screens/profile/profile_page.dart';
import 'package:tsdm_client/screens/root/root.dart';
import 'package:tsdm_client/screens/settings/about_page.dart';
import 'package:tsdm_client/screens/settings/settings_page.dart';
import 'package:tsdm_client/screens/thread/thread_page.dart';
import 'package:tsdm_client/screens/topic/topic.dart';
import 'package:tsdm_client/widgets/root_scaffold.dart';

final _rootRouteKey = GlobalKey<NavigatorState>();
final _shellRouteKey = GlobalKey<NavigatorState>();

/// All app routes.
///
/// Routes with global nav bar are under [ShellRoute]
/// https://github.com/flutter/packages/pull/2650#issuecomment-1561353369
final tClientRouter = GoRouter(
  navigatorKey: _rootRouteKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellRouteKey,
      builder: (context, router, navigator) => RootScaffold(
        showNavigationBar: true,
        child: navigator,
      ),
      routes: [
        AppRoute(
          path: ScreenPaths.homepage,
          parentNavigatorKey: _shellRouteKey,
          builder: (_) => const HomePage(),
        ),
        AppRoute(
          path: ScreenPaths.topic,
          parentNavigatorKey: _shellRouteKey,
          builder: (_) => const TopicPage(
            fetchUrl: homePage,
          ),
        ),
        AppRoute(
          path: ScreenPaths.profile,
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
      path: ScreenPaths.root,
      parentNavigatorKey: _rootRouteKey,
      builder: (_) => const RootPage(),
    ),
    AppRoute(
      path: ScreenPaths.forum,
      parentNavigatorKey: _rootRouteKey,
      builder: (state) {
        final extra = state.extra;
        String? title;
        if (extra != null && extra is Map<String, dynamic>) {
          title = extra['appBarTitle'] as String;
        }
        return ForumPage(
          title: title,
          fid: state.pathParameters['fid']!,
          routerState: state,
        );
      },
    ),
    AppRoute(
        path: ScreenPaths.thread,
        parentNavigatorKey: _rootRouteKey,
        builder: (state) {
          final extra = state.extra;
          String? title;
          String? threadType;
          if (extra != null && extra is Map<String, dynamic>) {
            title = extra['appBarTitle'] as String;
            threadType = extra['threadType'] as String?;
          }
          return ThreadPage(
            title: title,
            threadType: threadType,
            threadID: state.pathParameters['tid']!,
            pageNumber: state.pathParameters['pageNumber'] ?? '1',
          );
        }),
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
