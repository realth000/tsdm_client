import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/check_in_feeling.dart';
import 'package:tsdm_client/providers/color_scheme_provider.dart';
import 'package:tsdm_client/providers/image_cache_provider.dart';
import 'package:tsdm_client/providers/settings_provider.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/screens/settings/check_in_dialog.dart';
import 'package:tsdm_client/screens/settings/color_picker_dialog.dart';
import 'package:tsdm_client/screens/settings/language_dialog.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/widgets/section_list_tile.dart';
import 'package:tsdm_client/widgets/section_title_text.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final scrollController = ScrollController();

  Widget? _cacheSizeWidget;

  @override
  void initState() {
    super.initState();
    _calculateCacheSize();
  }

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

  Future<void> _calculateCacheSize() async {
    setState(() {
      _cacheSizeWidget = const Row(
        children: [sizedCircularProgressIndicator],
      );
    });
    // DO NOT AWAIT
    // ignore:unawaited_futures
    ref.read(imageCacheProvider.notifier).calculateCache().then((v) {
      const suffixes = ['b', 'kb', 'mb', 'gb', 'tb'];
      if (v == 0) {
        setState(() {
          _cacheSizeWidget = Text('0${suffixes[0]}');
        });
        return;
      }
      final i = (log(v) / log(1024)).floor();
      setState(() {
        _cacheSizeWidget =
            Text(((v / pow(1024, i)).toStringAsFixed(2)) + suffixes[i]);
      });
    }).onError((e, st) {
      setState(() {
        _cacheSizeWidget = const Text('-');
      });
      return null;
    });
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
      builder: (context) => const CheckInMessageDialog(),
    );
  }

  Future<void> _showAccentColorPickerDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const ColorPickerDialog(),
    );
  }

  Future<void> _showClearCacheDialog(BuildContext context) async {
    final result = await showQuestionDialog(
      title: context.t.settingsPage.storageSection.sureToClear,
      message: context.t.settingsPage.storageSection.downloadAgainInfo,
      context: context,
    );
    if (result != true) {
      return;
    }
    if (!mounted) {
      await ref.read(imageCacheProvider.notifier).clearCache();
      return;
    }
    // Clear cache
    await showModalWorkDialog(
      context: context,
      message: context.t.settingsPage.storageSection.clearCache,
      work: () async => ref.read(imageCacheProvider.notifier).clearCache(),
    );
    await _calculateCacheSize();
  }

  List<Widget> _buildAppearanceSection(BuildContext context) {
    final settingsLocale = ref.watch(appSettingsProvider).locale;
    final locale = AppLocale.values
        .firstWhereOrNull((v) => v.languageTag == settingsLocale);
    final localeName = locale == null
        ? context.t.settingsPage.appearanceSection.languages.followSystem
        : context.t.locale;

    final accentColor = ref.watch(appColorSchemeProvider);

    return [
      SectionTitleText(context.t.settingsPage.appearanceSection.title),
      // Theme mode
      SectionListTile(
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
      SectionListTile(
        leading: const Icon(Icons.translate_outlined),
        title: Text(context.t.settingsPage.appearanceSection.languages.title),
        subtitle: Text(localeName),
        onTap: () async {
          await selectLanguageDialog(context, localeName);
        },
      ),

      /// Shortcut in forum card.
      SwitchListTile(
        secondary: const Icon(Icons.shortcut_outlined),
        title: Text(context
            .t.settingsPage.appearanceSection.showShortcutInForumCard.title),
        subtitle: Text(context
            .t.settingsPage.appearanceSection.showShortcutInForumCard.detail),
        contentPadding: edgeInsetsL18R18,
        value: ref.read(appSettingsProvider).showShortcutInForumCard,
        onChanged: (v) async {
          await ref
              .read(appSettingsProvider.notifier)
              .setShowShortcutInForumCard(visible: v);
        },
      ),
      SectionListTile(
        leading: const Icon(Icons.color_lens_outlined),
        title: Text(context.t.settingsPage.appearanceSection.colorScheme.title),
        trailing: accentColor == null
            ? null
            : CircleAvatar(radius: 15, backgroundColor: accentColor),
        onTap: () async {
          await _showAccentColorPickerDialog(context);
        },
      ),
    ];
  }

  List<Widget> _buildCheckInSections(BuildContext context) {
    final checkInFeeling = ref.watch(appSettingsProvider).checkInFeeling;
    final checkInMessage = ref.watch(appSettingsProvider).checkInMessage;

    return [
      SectionTitleText(context.t.settingsPage.checkInSection.title),
      // Feeling
      SectionListTile(
        leading: const Icon(Icons.emoji_emotions_outlined),
        title: Text(context.t.settingsPage.checkInSection.feeling),
        subtitle: Text(CheckInFeeling.from(checkInFeeling).translate(context)),
        onTap: () async {
          await _showSetCheckInFeelingDialog(context);
        },
      ),
      // Message
      SectionListTile(
        leading: const Icon(Icons.textsms_outlined),
        title: Text(context.t.settingsPage.checkInSection.anythingToSay),
        subtitle: Text(checkInMessage),
        onTap: () async {
          await _showSetCheckInMessageDialog(context);
        },
      ),
    ];
  }

  List<Widget> _buildStorageSection(BuildContext context) {
    return [
      SectionTitleText(context.t.settingsPage.storageSection.title),
      SectionListTile(
        leading: const Icon(Icons.cleaning_services_outlined),
        title: Text(context.t.settingsPage.storageSection.clearCache),
        subtitle: _cacheSizeWidget,
        onTap: () async {
          await _showClearCacheDialog(context);
        },
      ),
    ];
  }

  List<Widget> _buildOtherSection(BuildContext context) {
    return [
      SectionTitleText(context.t.settingsPage.othersSection.title),
      // About
      SectionListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(context.t.settingsPage.othersSection.about),
        onTap: () async {
          await context.pushNamed(ScreenPaths.about);
        },
      ),

      /// Update
      SectionListTile(
        leading: const Icon(Icons.new_releases_outlined),
        title: Text(context.t.settingsPage.othersSection.upgrade),
        onTap: () async {
          await context.pushNamed(ScreenPaths.upgrade);
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
            ..._buildCheckInSections(context),
            ..._buildStorageSection(context),
            ..._buildOtherSection(context),
          ],
        ),
      ),
    );
  }
}
