import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/small_providers.dart';
import 'package:tsdm_client/routes/screen_paths.dart';

class _NavigationBarItem {
  _NavigationBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.targetPath,
  });

  final Icon icon;
  final Icon selectedIcon;
  final String label;
  final String targetPath;
}

class AppNavigationBar extends ConsumerStatefulWidget {
  const AppNavigationBar({super.key});

  @override
  ConsumerState<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends ConsumerState<AppNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final barItems = [
      _NavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: context.t.navigation.homepage,
        targetPath: ScreenPaths.homepage,
      ),
      _NavigationBarItem(
        icon: const Icon(Icons.topic_outlined),
        selectedIcon: const Icon(Icons.topic),
        label: context.t.navigation.topics,
        targetPath: ScreenPaths.topic,
      ),
      _NavigationBarItem(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: context.t.navigation.profile,
        targetPath: ScreenPaths.profile,
      ),
      _NavigationBarItem(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: context.t.navigation.settings,
        targetPath: ScreenPaths.settings,
      ),
    ];

    return NavigationBar(
      destinations: barItems
          .map((e) => NavigationDestination(
              icon: e.icon, selectedIcon: e.selectedIcon, label: e.label))
          .toList(),
      selectedIndex: ref.watch(appNavigationBarIndexProvider),
      onDestinationSelected: (index) {
        ref.read(appNavigationBarIndexProvider.notifier).state = index;
        context.goNamed(barItems[index].targetPath);
      },
    );
  }
}
