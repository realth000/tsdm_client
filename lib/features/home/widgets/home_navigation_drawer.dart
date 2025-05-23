part of 'widgets.dart';

/// [NavigationDrawer] used in home page.
///
/// Use in large or extra-large window.
class HomeNavigationDrawer extends StatelessWidget {
  /// Constructor.
  const HomeNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final barItems = _buildNavigationItems(context);
    return NavigationDrawer(
      selectedIndex: context.watch<HomeCubit>().state.tab.index,
      onDestinationSelected: (index) {
        context.read<HomeCubit>().setTab(barItems[index].tab);
        context.goNamed(barItems[index].targetPath);
      },
      children: barItems
          .map((e) => NavigationDrawerDestination(icon: e.icon, selectedIcon: e.selectedIcon, label: Text(e.label)))
          .toList(),
    );
  }
}
