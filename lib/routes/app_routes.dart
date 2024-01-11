import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/features/home/view/home_page.dart';
import 'package:tsdm_client/features/homepage/view/homepage_page.dart';
import 'package:tsdm_client/features/profile/view/profile_page.dart';
import 'package:tsdm_client/features/settings/view/about_page.dart';
import 'package:tsdm_client/features/settings/view/settings_page.dart';
import 'package:tsdm_client/features/settings/widgets/app_license_page.dart';
import 'package:tsdm_client/features/topics/view/topics_page.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';

final _rootRouteKey = GlobalKey<NavigatorState>();
final _shellRouteKey = GlobalKey<NavigatorState>();

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
