import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/settings_provider.dart';
import 'package:tsdm_client/screens/settings/language_dialog.dart';
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

  Future<void> selectLanguageDialog(
    BuildContext context,
    String currentLocale,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => const LanguageDialog(),
    );
  }

  List<Widget> _buildAppearanceSection(BuildContext context) {
    final settingsLocale = ref.watch(appSettingsProvider).locale;
    final locale = AppLocale.values
        .firstWhereOrNull((v) => v.languageTag == settingsLocale);
    final localeName = locale == null
        ? context.t.settingsPage.appearanceSection.languages.followSystem
        : context.t.locale;

    return [
      // Appearance
      SectionTitleText(context.t.settingsPage.appearanceSection.title),
      // Theme mode
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        title: Text(context.t.settingsPage.appearanceSection.themeMode.title),
        subtitle: Text(
          <String>[
            context.t.settingsPage.appearanceSection.themeMode.system,
            context.t.settingsPage.appearanceSection.themeMode.light,
            context.t.settingsPage.appearanceSection.themeMode.dark,
          ][ref.watch(appSettingsProvider).themeMode],
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
      // Language
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        title: Text(context.t.settingsPage.appearanceSection.languages.title),
        subtitle: Text(localeName),
        onTap: () async {
          await selectLanguageDialog(context, localeName);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.navigation.settings)),
      body: Scrollbar(
        controller: scrollController,
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
