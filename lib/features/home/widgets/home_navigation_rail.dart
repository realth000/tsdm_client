part of 'widgets.dart';

/// [NavigationRail] used in home page.
///
/// Use in medium window size.
class HomeNavigationRail extends StatelessWidget {
  /// Constructor.
  const HomeNavigationRail({super.key});

  @override
  Widget build(BuildContext context) {
    final barItems = _buildNavigationItems(context);

    return NavigationRail(
      groupAlignment: 0,
      destinations: barItems
          .map(
            (e) => NavigationRailDestination(
              icon: e.icon,
              selectedIcon: e.selectedIcon,
              label: Text(e.label),
            ),
          )
          .toList(),
      selectedIndex: context.watch<HomeCubit>().state.tab.index,
      onDestinationSelected: (index) {
        context.read<HomeCubit>().setTab(barItems[index].tab);
        context.goNamed(barItems[index].targetPath);
      },
    );
  }
}
