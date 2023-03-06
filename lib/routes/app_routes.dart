import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/forum/forum_page.dart';
import '../screens/homepage/homepage.dart';
import '../widgets/app_scaffold.dart';

/// All app routes.
class TClientRoute {
  /// App about page.
  static const String about = '/about';

  /// Sub form page.
  ///
  /// Need to specify forum id (fid).
  static const String forum = '/forum/:fid';

  /// Homepage: "https://www.tsdm39.net/forum.php"
  static const String homepage = '/';

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
}

/// All app routes.
final tClientRouter = GoRouter(
  routes: [
    AppRoute(
      path: TClientRoute.homepage,
      appBarTitle: '论坛首页',
      builder: (_) => const TCHomePage(
        fetchUrl: 'https://www.tsdm39.net/forum.php',
      ),
    ),
    AppRoute(
      path: TClientRoute.forum,
      builder: (state) => ForumPage(
        fid: state.params['fid']!,
      ),
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
    super.redirect,
  }) : super(
          name: path,
          routes: routes,
          pageBuilder: (context, state) => MaterialPage(
            name: path,
            arguments: state.params,
            child: _buildScaffold(
              state,
              builder,
              appBarTitle: appBarTitle,
            ),
          ),
        );

  static TClientScaffold _buildScaffold(
    GoRouterState state,
    Widget Function(GoRouterState s) builder, {
    String? appBarTitle,
  }) {
    if (state.extra != null && state.extra is Map<String, String>) {
      final extra = state.extra as Map<String, String>;
      return TClientScaffold(
        body: builder(state),
        appBarTitle: extra['appBarTitle'] ?? appBarTitle,
      );
    } else {
      return TClientScaffold(
        body: builder(state),
        appBarTitle: appBarTitle,
      );
    }
  }
}
