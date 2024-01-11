part of 'home_cubit.dart';

/// All tabs in homepage of the app.
///
/// Not the homepage of website nor the [home] tab.
enum HomeTab {
  /// Homepage of the forum website except forum list/groups part.
  ///
  /// Provides data fetched from baseUrl.
  home,

  /// All top-level forums showed in homepage with forum group.
  topic,

  /// Current logged user's profile.
  ///
  /// Only the current logged user and any entries comes from user's contents
  /// including post and thread will not redirect to this tab.
  /// Because we do not know if the author of content is the logged user or not.
  profile,

  /// Settings page of the app.
  settings,
}

/// State of the homepage of the app.
final class HomeState extends Equatable {
  const HomeState({this.tab = HomeTab.home});

  /// Current tab.
  final HomeTab tab;

  @override
  List<Object?> get props => [tab];
}

class NavigationBarItem {
  NavigationBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.targetPath,
    required this.tab,
  });

  final Icon icon;
  final Icon selectedIcon;
  final String label;
  final String targetPath;
  final HomeTab tab;
}

final barItems = [
  NavigationBarItem(
    icon: const Icon(Icons.home_outlined),
    selectedIcon: const Icon(Icons.home),
    label: t.navigation.homepage,
    targetPath: ScreenPaths.homepage,
    tab: HomeTab.home,
  ),
  NavigationBarItem(
    icon: const Icon(Icons.topic_outlined),
    selectedIcon: const Icon(Icons.topic),
    label: t.navigation.topics,
    targetPath: ScreenPaths.topic,
    tab: HomeTab.topic,
  ),
  NavigationBarItem(
    icon: const Icon(Icons.person_outline),
    selectedIcon: const Icon(Icons.person),
    label: t.navigation.profile,
    targetPath: ScreenPaths.loggedUserProfile,
    tab: HomeTab.profile,
  ),
  NavigationBarItem(
    icon: const Icon(Icons.settings_outlined),
    selectedIcon: const Icon(Icons.settings),
    label: t.navigation.settings,
    targetPath: ScreenPaths.settings,
    tab: HomeTab.settings,
  ),
];
