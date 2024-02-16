import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/features/settings/widgets/cache_status_widget.dart';
import 'package:tsdm_client/features/settings/widgets/check_in_dialog.dart';
import 'package:tsdm_client/features/settings/widgets/color_picker_dialog.dart';
import 'package:tsdm_client/features/settings/widgets/language_dialog.dart';
import 'package:tsdm_client/features/theme/cubit/theme_cubit.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/check_in_feeling.dart';
import 'package:tsdm_client/shared/repositories/fragments_repository/fragments_repository.dart';
import 'package:tsdm_client/shared/repositories/settings_repository/settings_repository.dart';
import 'package:tsdm_client/widgets/section_list_tile.dart';
import 'package:tsdm_client/widgets/section_title_text.dart';

/// Settings page of the app.
class SettingsPage extends StatefulWidget {
  /// Constructor.
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final scrollController = ScrollController();

  /// Show a dialog to let user select locale.
  ///
  /// * Return null if user canceled the selection.
  /// * Return (null, true) if user chose to use system locale.
  /// * Return (locale, false) if user chose to use specified locale.
  Future<(AppLocale?, bool)?> selectLanguageDialog(
    BuildContext context,
    String currentLocale,
  ) async {
    return showDialog<(AppLocale?, bool)>(
      context: context,
      builder: (context) => LanguageDialog(currentLocale),
    );
  }

  /// Show a dialog to let user select accent color.
  ///
  /// * Return null if user canceled the selection.
  /// * Return (null, true) if user chose to use default color.
  /// * Return (color, false) if user chose to use specified color.
  Future<(Color?, bool)?> _showAccentColorPickerDialog(
    BuildContext context,
  ) async {
    return showDialog<(Color?, bool)>(
      context: context,
      builder: (context) => const ColorPickerDialog(),
    );
  }

  List<Widget> _buildAppearanceSection(
    BuildContext context,
    SettingsState state,
  ) {
    // Locale.
    final settingsLocale = state.settingsMap.locale;
    final locale = AppLocale.values
        .firstWhereOrNull((v) => v.languageTag == settingsLocale);
    final localeName = locale == null
        ? context.t.settingsPage.appearanceSection.languages.followSystem
        : context.t.locale;

    // Theme mode.
    final themeModeIndex = state.settingsMap.themeMode;

    // ForumCard shortcut;
    final showForumCardShortcut = state.settingsMap.showShortcutInForumCard;

    // Accent color.
    final accentColor = state.settingsMap.accentColor;

    // Show badge or unread info count on logged user's unread messages;
    final showUnreadInfoHint = state.settingsMap.showUnreadInfoHint;

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
          ][themeModeIndex],
        ),
        trailing: ToggleButtons(
          isSelected: [
            themeModeIndex == ThemeMode.light.index,
            themeModeIndex == ThemeMode.system.index,
            themeModeIndex == ThemeMode.dark.index,
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
            // Effect immediately.
            context.read<ThemeCubit>().setThemeModeIndex(themeIndex);
            // Save to settings.
            context
                .read<SettingsBloc>()
                .add(SettingsChangeThemeModeRequested(themeIndex));
          },
        ),
      ),
      // Language
      SectionListTile(
        leading: const Icon(Icons.translate_outlined),
        title: Text(context.t.settingsPage.appearanceSection.languages.title),
        subtitle: Text(localeName),
        onTap: () async {
          final localeGroup =
              await selectLanguageDialog(context, locale?.languageTag ?? '');
          if (localeGroup == null) {
            return;
          }
          if (localeGroup.$2) {
            // Use system language.
            LocaleSettings.useDeviceLocale();
            if (!context.mounted) {
              return;
            }
            context
                .read<SettingsBloc>()
                .add(const SettingsChangeLocaleRequested(''));
            return;
          }
          if (!context.mounted) {
            return;
          }
          LocaleSettings.setLocale(localeGroup.$1!);
          context
              .read<SettingsBloc>()
              .add(SettingsChangeLocaleRequested(localeGroup.$1!.languageTag));
        },
      ),

      /// Shortcut in forum card.
      SwitchListTile(
        secondary: const Icon(Icons.shortcut_outlined),
        title: Text(
          context
              .t.settingsPage.appearanceSection.showShortcutInForumCard.title,
        ),
        subtitle: Text(
          context
              .t.settingsPage.appearanceSection.showShortcutInForumCard.detail,
        ),
        contentPadding: edgeInsetsL18R18,
        value: showForumCardShortcut,
        onChanged: (v) async {
          context
              .read<SettingsBloc>()
              .add(SettingsChangeForumCardShortcutRequested(showShortcut: v));
        },
      ),
      // Accent color
      SectionListTile(
        leading: const Icon(Icons.color_lens_outlined),
        title: Text(context.t.settingsPage.appearanceSection.colorScheme.title),
        trailing: accentColor < 0
            ? null
            : CircleAvatar(radius: 15, backgroundColor: Color(accentColor)),
        onTap: () async {
          final color = await _showAccentColorPickerDialog(context);
          if (color == null) {
            return;
          }
          if (!context.mounted) {
            return;
          }
          if (color.$2) {
            // Effect immediately.
            context.read<ThemeCubit>().clearAccentColor();
            context
                .read<SettingsBloc>()
                .add(const SettingClearAccentColorRequested());
            return;
          }
          context.read<ThemeCubit>().setAccentColor(color.$1!);
          context
              .read<SettingsBloc>()
              .add(SettingsChangeAccentColorRequested(color.$1!));
        },
      ),
      SwitchListTile(
        secondary: const Icon(Icons.notifications_outlined),
        title: Text(
          context.t.settingsPage.appearanceSection.showUnreadInfoHint.title,
        ),
        subtitle: Text(
          context.t.settingsPage.appearanceSection.showUnreadInfoHint.detail,
        ),
        contentPadding: edgeInsetsL18R18,
        value: showUnreadInfoHint,
        onChanged: (v) async {
          context
              .read<SettingsBloc>()
              .add(SettingsChangeUnreadInfoHintRequested(enabled: v));
        },
      ),
    ];
  }

  Future<String?> _showSetCheckinFeelingDialog(
    BuildContext context,
    String defaultFeeling,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) => CheckinFeelingDialog(defaultFeeling),
    );
  }

  Future<String?> _showSetCheckinMessageDialog(
    BuildContext context,
    String defaultMessage,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) => CheckinMessageDialog(defaultMessage),
    );
  }

  List<Widget> _buildCheckinSection(
    BuildContext context,
    SettingsState state,
  ) {
    final checkinFeeling = state.settingsMap.checkinFeeling;
    final checkinMessage = state.settingsMap.checkinMessage;

    return [
      SectionTitleText(context.t.settingsPage.checkinSection.title),
      // Feeling
      SectionListTile(
        leading: const Icon(Icons.emoji_emotions_outlined),
        title: Text(context.t.settingsPage.checkinSection.feeling),
        subtitle: Text(CheckinFeeling.from(checkinFeeling).translate(context)),
        onTap: () async {
          final result =
              await _showSetCheckinFeelingDialog(context, checkinFeeling);
          if (result == null) {
            return;
          }
          if (!context.mounted) {
            return;
          }
          context.read<SettingsBloc>().add(
                SettingsChangeCheckinFeelingRequested(
                  CheckinFeeling.from(result),
                ),
              );
        },
      ),
      // Message
      SectionListTile(
        leading: const Icon(Icons.textsms_outlined),
        title: Text(context.t.settingsPage.checkinSection.anythingToSay),
        subtitle: Text(checkinMessage),
        onTap: () async {
          final result =
              await _showSetCheckinMessageDialog(context, checkinMessage);
          if (result == null) {
            return;
          }
          if (!context.mounted) {
            return;
          }
          context
              .read<SettingsBloc>()
              .add(SettingsChangeCheckingMessageRequested(result));
        },
      ),
    ];
  }

  List<Widget> _buildStorageSection(
    BuildContext context,
    SettingsState state,
  ) {
    return [
      // Cache.
      SectionTitleText(context.t.settingsPage.storageSection.title),
      const CacheStatusWidget(),
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
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(
        fragmentsRepository:
            RepositoryProvider.of<FragmentsRepository>(context),
        settingsRepository: RepositoryProvider.of<SettingsRepository>(context),
      ),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.t.navigation.settings),
            ),
            body: ListView(
              controller: scrollController,
              children: [
                ..._buildAppearanceSection(context, state),
                ..._buildCheckinSection(context, state),
                ..._buildStorageSection(context, state),
                ..._buildOtherSection(context),
              ],
            ),
          );
        },
      ),
    );
  }
}
