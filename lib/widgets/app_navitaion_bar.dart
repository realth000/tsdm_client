import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/small_providers.dart';
import 'package:tsdm_client/routes/app_routes.dart';

class _NavigationBarItem {
  _NavigationBarItem({required this.icon, required this.label});

  final Icon icon;
  final String label;
}

final _barItems = [
  _NavigationBarItem(icon: const Icon(Icons.home), label: '首页'),
  _NavigationBarItem(icon: const Icon(Icons.person), label: '我的'),
  _NavigationBarItem(icon: const Icon(Icons.settings), label: '设置'),
];

class AppNavigationBar extends ConsumerStatefulWidget {
  const AppNavigationBar({super.key});

  @override
  ConsumerState<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends ConsumerState<AppNavigationBar> {
  void _gotoTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(ScreenPaths.homepage);
      case 1:
        context.go(ScreenPaths.profile);
      case 2:
        context.go(ScreenPaths.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: _barItems
          .map((e) => NavigationDestination(icon: e.icon, label: e.label))
          .toList(),
      selectedIndex: ref.watch(appNavigationBarIndexProvider),
      onDestinationSelected: (index) {
        ref.read(appNavigationBarIndexProvider.notifier).state = index;
        _gotoTab(context, index);
      },
    );
  }
}
