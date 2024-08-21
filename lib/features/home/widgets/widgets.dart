import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/features/home/cubit/home_cubit.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';

part 'home_navigation_bar.dart';
part 'home_navigation_drawer.dart';
part 'home_navigation_rail.dart';

/// Bar item in app navigator.
final class _NavigationItem {
  /// Constructor.
  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.targetPath,
    required this.tab,
  });

  /// Item icon.
  ///
  /// Use outline style icons.
  final Icon icon;

  /// Item icon when selected.
  ///
  /// Use normal style icons.
  final Icon selectedIcon;

  /// Name of the item.
  final String label;

  /// Screen path of the item.
  final String targetPath;

  /// Tab index.
  final HomeTab tab;
}

/// All navigation bar items.
List<_NavigationItem> _buildNavigationItems(BuildContext context) => [
      _NavigationItem(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: context.t.navigation.homepage,
        targetPath: ScreenPaths.homepage,
        tab: HomeTab.home,
      ),
      _NavigationItem(
        icon: const Icon(Icons.topic_outlined),
        selectedIcon: const Icon(Icons.topic),
        label: context.t.navigation.topics,
        targetPath: ScreenPaths.topic,
        tab: HomeTab.topic,
      ),
      _NavigationItem(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: context.t.navigation.settings,
        targetPath: ScreenPaths.settings.path,
        tab: HomeTab.settings,
      ),
    ];
