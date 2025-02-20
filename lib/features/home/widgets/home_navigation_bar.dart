part of 'widgets.dart';

/// [NavigationBar] used in home page.
///
/// Use in compact window.
class HomeNavigationBar extends StatelessWidget {
  /// Constructor.
  const HomeNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final barItems = _buildNavigationItems(context);

    return NavigationBar(
      destinations:
          barItems
              .map((e) => NavigationDestination(icon: e.icon, selectedIcon: e.selectedIcon, label: e.label))
              .toList(),
      selectedIndex: context.watch<HomeCubit>().state.tab.index,
      onDestinationSelected: (index) {
        context.read<HomeCubit>().setTab(barItems[index].tab);
        context.goNamed(barItems[index].targetPath);
      },
    );
  }
}
