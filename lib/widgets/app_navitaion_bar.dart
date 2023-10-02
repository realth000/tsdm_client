import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/small_providers.dart';
import 'package:tsdm_client/routes/screen_paths.dart';

class _NavigationBarItem {
  _NavigationBarItem({
    required this.icon,
    required this.label,
    required this.targetPath,
  });

  final Icon icon;
  final String label;
  final String targetPath;
}

final _barItems = [
  _NavigationBarItem(
    icon: const Icon(Icons.home),
    label: '首页',
    targetPath: ScreenPaths.homepage,
  ),
  _NavigationBarItem(
    icon: const Icon(Icons.topic),
    label: 'Topics',
    targetPath: ScreenPaths.topic,
  ),
  // _NavigationBarItem(
  //     icon: const Icon(Icons.person),
  //     label: '我的',
  //     targetPath: ScreenPaths.profile),
  _NavigationBarItem(
    icon: const Icon(Icons.settings),
    label: '设置',
    targetPath: ScreenPaths.settings,
  ),
];

class AppNavigationBar extends ConsumerStatefulWidget {
  const AppNavigationBar({super.key});

  @override
  ConsumerState<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends ConsumerState<AppNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: _barItems
          .map((e) => NavigationDestination(icon: e.icon, label: e.label))
          .toList(),
      selectedIndex: ref.watch(appNavigationBarIndexProvider),
      onDestinationSelected: (index) {
        ref.read(appNavigationBarIndexProvider.notifier).state = index;
        context.goNamed(_barItems[index].targetPath);
      },
    );
  }
}
