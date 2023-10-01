import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/screens/forum/forum_page.dart';
import 'package:tsdm_client/screens/homepage/homepage.dart';
import 'package:tsdm_client/screens/login/login_page.dart';
import 'package:tsdm_client/screens/profile/profile_page.dart';
import 'package:tsdm_client/screens/root/root.dart';
import 'package:tsdm_client/screens/thread/thread_page.dart';
import 'package:tsdm_client/screens/topic/topic.dart';
import 'package:tsdm_client/widgets/app_scaffold.dart';
import 'package:tsdm_client/widgets/root_scaffold.dart';

final shellRouteNavigatorKey = GlobalKey<NavigatorState>();

/// All app routes.
class ScreenPaths {
  /// Root page to load [homepage].
  static const String root = '/';

  /// App about page.
  static const String about = '/about';

  /// Sub form page.
  ///
  /// Need to specify forum id (fid).
  static const String forum = '/forum/:fid';

  /// Homepage: "https://www.tsdm39.com/forum.php"
  ///
  /// Only the very first part of page.
  static const String homepage = '/homepage';

  /// Homepage: "https://www.tsdm39.com/forum.php"
  ///
  /// Rest part of homepage, including all topics.
  /// Contains groups of sub-forums.
  static const String topic = '/topic';

  /// App login page.
  ///
  /// Redirect to user profile page.
  static const String login = '/login';

  /// Another login page, uses when website requires to login.
  ///
  /// Redirect to former page when successfully login,
  /// need to specify the former page.
  static const String loginRedirect = '/login/redirect';

  /// User profile page.
  ///
  /// Need to specify username (username).
  static const String profile = '/profile/:username';

  /// App settings page.
  static const String settings = '/settings';

  /// Thread page.
  static const String thread = '/thread/:tid';
}

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
          appBarTitle: 'Homepage',
          builder: (_) => const HomePage(),
          buildNavigator: true,
        ),
        AppRoute(
          path: ScreenPaths.topic,
          builder: (_) => const TopicPage(
            fetchUrl: 'https://www.tsdm39.com/forum.php',
          ),
          buildNavigator: true,
        ),
        AppRoute(
          path: ScreenPaths.forum,
          builder: (state) => ForumPage(
            fid: state.pathParameters['fid']!,
            routerState: state,
          ),
        ),
        AppRoute(
          path: ScreenPaths.thread,
          builder: (state) => ThreadPage(
            threadID: state.pathParameters['tid']!,
            pageNumber: state.pathParameters['pageNumber'] ?? '1',
          ),
        ),
        AppRoute(
          path: ScreenPaths.profile,
          builder: (state) => ProfilePage(
            uid: state.pathParameters['uid'],
          ),
        ),
        AppRoute(
          path: ScreenPaths.login,
          builder: (state) {
            final loginArgsMap = state.extra as Map<String, dynamic>;
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
    String? appBarTitle,
    bool buildNavigator = false,
    super.redirect,
  }) : super(
          name: path,
          routes: routes,
          pageBuilder: (context, state) => MaterialPage<void>(
            name: path,
            arguments: state.pathParameters,
            child: _buildScaffold(
              state,
              builder,
              buildNavigator,
              appBarTitle: appBarTitle,
            ),
          ),
        );

  static TClientScaffold _buildScaffold(
    GoRouterState state,
    Widget Function(GoRouterState s) builder,
    bool buildNavigator, {
    String? appBarTitle,
  }) {
    if (state.extra != null) {
      final extra = state.extra as Map<String, dynamic>;
      return TClientScaffold(
        body: builder(state),
        appBarTitle: extra['appBarTitle'] is String
            ? extra['appBarTitle'] as String
            : appBarTitle,
        buildNavigator: buildNavigator,
      );
    } else {
      return TClientScaffold(
        body: builder(state),
        appBarTitle: appBarTitle,
        buildNavigator: buildNavigator,
      );
    }
  }
}
