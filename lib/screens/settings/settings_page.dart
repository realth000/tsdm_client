import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/check_in_feeling.dart';
import 'package:tsdm_client/providers/settings_provider.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/screens/settings/check_in_dialog.dart';
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

  Future<void> _showSetCheckInFeelingDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const CheckInFeelingDialog(),
    );
  }

  Future<void> _showSetCheckInMessageDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => CheckInMessageDialog(),
    );
  }

  List<Widget> _buildAppearanceSection(BuildContext context) {
    final settingsLocale = ref.watch(appSettingsProvider).locale;

    final checkInFeeling = ref.watch(appSettingsProvider).checkInFeeling;
    final checkInMessage = ref.watch(appSettingsProvider).checkInMessage;

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
        leading: const Icon(Icons.contrast_outlined),
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
            Icon(Icons.light_mode_outlined),
            Icon(Icons.auto_mode_outlined),
            Icon(Icons.dark_mode_outlined),
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
        leading: const Icon(Icons.translate_outlined),
        title: Text(context.t.settingsPage.appearanceSection.languages.title),
        subtitle: Text(localeName),
        onTap: () async {
          await selectLanguageDialog(context, localeName);
        },
      ),
      SectionTitleText(context.t.settingsPage.checkInSection.title),
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        leading: const Icon(Icons.emoji_emotions_outlined),
        title: Text(context.t.settingsPage.checkInSection.feeling),
        subtitle: Text(CheckInFeeling.from(checkInFeeling).translate(context)),
        onTap: () async {
          await _showSetCheckInFeelingDialog(context);
        },
      ),
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        leading: const Icon(Icons.textsms_outlined),
        title: Text(context.t.settingsPage.checkInSection.anythingToSay),
        subtitle: Text(checkInMessage),
        onTap: () async {
          await _showSetCheckInMessageDialog(context);
        },
      ),
      // Others
      SectionTitleText(context.t.settingsPage.othersSection.title),
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        leading: const Icon(Icons.info_outline),
        title: Text(context.t.settingsPage.othersSection.about),
        onTap: () async {
          await context.pushNamed(ScreenPaths.about);
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
