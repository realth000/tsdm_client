import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/screens/forum/forum_page.dart';
import 'package:tsdm_client/screens/homepage/homepage.dart';
import 'package:tsdm_client/screens/login/login_page.dart';
import 'package:tsdm_client/screens/profile/profile_page.dart';
import 'package:tsdm_client/screens/root/root.dart';
import 'package:tsdm_client/screens/settings/settings_page.dart';
import 'package:tsdm_client/screens/thread/thread_page.dart';
import 'package:tsdm_client/screens/topic/topic.dart';
import 'package:tsdm_client/widgets/root_scaffold.dart';

final shellRouteNavigatorKey = GlobalKey<NavigatorState>();

/// All app routes.
final tClientRouter = GoRouter(
  routes: [
    ShellRoute(
      navigatorKey: shellRouteNavigatorKey,
      builder: (context, router, navigator) => RootScaffold(child: navigator),
      routes: [
        AppRoute(
          path: ScreenPaths.root,
          builder: (_) => const RootPage(),
        ),
        AppRoute(
          path: ScreenPaths.homepage,
          builder: (_) => const HomePage(),
        ),
        AppRoute(
          path: ScreenPaths.topic,
          builder: (_) => const TopicPage(
            fetchUrl: 'https://www.tsdm39.com/forum.php',
          ),
        ),
        AppRoute(
          path: ScreenPaths.settings,
          builder: (_) => const SettingsPage(),
        ),
        AppRoute(
          path: ScreenPaths.forum,
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
            builder: (state) {
              final extra = state.extra;
              String? title;
              if (extra != null && extra is Map<String, dynamic>) {
                title = extra['appBarTitle'] as String;
              }
              return ThreadPage(
                title: title,
                threadID: state.pathParameters['tid']!,
                pageNumber: state.pathParameters['pageNumber'] ?? '1',
              );
            }),
        AppRoute(
          path: ScreenPaths.profile,
          builder: (state) => ProfilePage(
            uid: state.pathParameters['uid'],
          ),
        ),
        AppRoute(
          path: ScreenPaths.login,
          builder: (state) {
            final loginArgsMap = state.extra! as Map<String, dynamic>;
            final redirectBackState =
                loginArgsMap['redirectBackState'] as GoRouterState;
            return LoginPage(redirectBackState: redirectBackState);
          },
        ),
      ],
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
