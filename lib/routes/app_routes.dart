import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      appBarTitle: 'HomePage',
      path: TClientRoute.homepage,
      builder: (_) => const TCHomePage(
        fetchUrl: 'https://www.tsdm39.net/forum.php',
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
  }) : super(
          routes: routes,
          pageBuilder: (context, state) {
            final pageContent = TClientScaffold(
              body: builder(state),
              appBarTitle: appBarTitle,
              // resizeToAvoidBottomInset: false,
            );
            return MaterialPage(child: pageContent);
          },
        );
}
