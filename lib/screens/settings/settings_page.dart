import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/settings_provider.dart';
import 'package:tsdm_client/widgets/section_title_text.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  List<Widget> _buildAppearanceSection(BuildContext context) {
    return [
      const SectionTitleText('Appearance'),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Theme Mode'),
        subtitle: Text(
          ThemeMode.values[ref.watch(appSettingsProvider).themeMode]
              .toString()
              .split('.')[1],
        ),
        trailing: ToggleButtons(
          isSelected: [
            ref.watch(appSettingsProvider).themeMode == ThemeMode.light.index,
            ref.watch(appSettingsProvider).themeMode == ThemeMode.system.index,
            ref.watch(appSettingsProvider).themeMode == ThemeMode.dark.index,
          ],
          children: const [
            Icon(Icons.light_mode),
            Icon(Icons.auto_mode),
            Icon(Icons.dark_mode),
          ],
          onPressed: (index) async {
            // Default: ThemeData.system.
            var themeIndex = 0;
            switch (index) {
              case 0:
                // Default: ThemeData.light.
                themeIndex = 1;
              case 1:
                // Default: ThemeData.system.
                themeIndex = 0;
              case 2:
                // Default: ThemeData.dark.
                themeIndex = 2;
            }
            await ref
                .read(appSettingsProvider.notifier)
                .setThemeMode(themeIndex);
          },
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: ListView(
          controller: scrollController,
          children: [
            ..._buildAppearanceSection(context),
          ],
        ),
      ),
    );
  }
}
