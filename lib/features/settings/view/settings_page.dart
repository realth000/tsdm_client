import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/features/settings/widgets/check_in_dialog.dart';
import 'package:tsdm_client/features/settings/widgets/clear_cache_bottom_sheet.dart';
import 'package:tsdm_client/features/settings/widgets/color_picker_dialog.dart';
import 'package:tsdm_client/features/settings/widgets/language_dialog.dart';
import 'package:tsdm_client/features/settings/widgets/proxy_settings_dialog.dart';
import 'package:tsdm_client/features/theme/cubit/theme_cubit.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/check_in_feeling.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/utils/show_bottom_sheet.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/section_list_tile.dart';
import 'package:tsdm_client/widgets/section_switch_list_tile.dart';
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
    final colorValue =
        getIt.get<SettingsRepository>().currentSettings.accentColor;
    if (!context.mounted) {
      return null;
    }
    return showCustomBottomSheet<(Color?, bool)>(
      title: context.t.colorPickerDialog.title,
      context: context,
      builder: (context) => ColorPickerDialog(
        currentColorValue: colorValue,
        blocContext: context,
      ),
    );
  }

  List<Widget> _buildAppearanceSection(
    BuildContext context,
    SettingsState state,
  ) {
    final tr = context.t.settingsPage.appearanceSection;
    // Locale.
    final settingsLocale = state.settingsMap.locale;
    final locale = AppLocale.values
        .firstWhereOrNull((v) => v.languageTag == settingsLocale);
    final localeName =
        locale == null ? tr.languages.followSystem : context.t.locale;

    // Theme mode.
    final themeModeIndex = state.settingsMap.themeMode;

    // ForumCard shortcut;
    final showForumCardShortcut = state.settingsMap.showShortcutInForumCard;

    // Accent color.
    final accentColor = state.settingsMap.accentColor;

    // Show badge or unread info count on logged user's unread messages;
    final showUnreadInfoHint = state.settingsMap.showUnreadInfoHint;

    return [
      SectionTitleText(tr.title),
      // Theme mode
      SectionListTile(
        leading: const Icon(Icons.contrast),
        title: Text(tr.themeMode.title),
        subtitle: Text(
          <String>[
            tr.themeMode.system,
            tr.themeMode.light,
            tr.themeMode.dark,
          ][themeModeIndex],
        ),
        trailing: ToggleButtons(
          isSelected: [
            themeModeIndex == ThemeMode.light.index,
            themeModeIndex == ThemeMode.system.index,
            themeModeIndex == ThemeMode.dark.index,
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
            // Effect immediately.
            context.read<ThemeCubit>().setThemeModeIndex(themeIndex);
            // Save to settings.
            context
                .read<SettingsBloc>()
                .add(SettingsValueChanged(SettingsKeys.themeMode, themeIndex));
          },
        ),
      ),
      // Language
      SectionListTile(
        leading: const Icon(Icons.translate),
        title: Text(tr.languages.title),
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
                .add(const SettingsValueChanged(SettingsKeys.locale, ''));
            return;
          }
          if (!context.mounted) {
            return;
          }
          LocaleSettings.setLocale(localeGroup.$1!);
          context.read<SettingsBloc>().add(
                SettingsValueChanged(
                  SettingsKeys.locale,
                  localeGroup.$1!.languageTag,
                ),
              );
        },
      ),

      /// Shortcut in forum card.
      SectionSwitchListTile(
        secondary: const Icon(Icons.shortcut),
        title: Text(tr.showShortcutInForumCard.title),
        subtitle: Text(tr.showShortcutInForumCard.detail),
        value: showForumCardShortcut,
        onChanged: (v) async {
          context.read<SettingsBloc>().add(
                SettingsValueChanged(
                  SettingsKeys.showShortcutInForumCard,
                  v,
                ),
              );
        },
      ),
      // Accent color
      SectionListTile(
        leading: const Icon(Icons.color_lens),
        title: Text(tr.colorScheme.title),
        trailing: accentColor < 0
            ? null
            : Hero(
                tag: Color(accentColor).toString(),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(accentColor),
                ),
              ),
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
            context
                .read<ThemeCubit>()
                .setAccentColor(Color(SettingsKeys.accentColor.defaultValue));
            // Set to -1 ( < 0) will clear accent color.
            context.read<SettingsBloc>().add(
                  SettingsValueChanged(
                    SettingsKeys.accentColor,
                    SettingsKeys.accentColor.defaultValue,
                  ),
                );
            return;
          }
          context.read<ThemeCubit>().setAccentColor(color.$1!);
          context.read<SettingsBloc>().add(
                SettingsValueChanged(SettingsKeys.accentColor, color.$1!.value),
              );
        },
      ),
      SectionSwitchListTile(
        secondary: const Icon(Icons.notifications),
        title: Text(tr.showUnreadInfoHint.title),
        subtitle: Text(tr.showUnreadInfoHint.detail),
        value: showUnreadInfoHint,
        onChanged: (v) async {
          context
              .read<SettingsBloc>()
              .add(SettingsValueChanged(SettingsKeys.showUnreadInfoHint, v));
        },
      ),
      SectionListTile(
        leading: const Icon(Icons.article),
        title: Text(tr.threadCard.title),
        subtitle: Text(tr.threadCard.detail),
        onTap: () =>
            context.pushNamed(ScreenPaths.settingsThreadAppearance.path),
        // onTap: () async => showCustomBottomSheet(
        //   context: context,
        //   title: tr.title,
        //   builder: (context) => const ThreadCardDialog(),
        //   constraints: const BoxConstraints(maxHeight: 400),
        // ),
      ),
    ];
  }

  List<Widget> _buildBehaviorSection(
    BuildContext context,
    SettingsState state,
  ) {
    final tr = context.t.settingsPage.behaviorSection;
    final doublePressExit = state.settingsMap.doublePressExit;
    final threadReverseOrder = state.settingsMap.threadReverseOrder;

    return [
      SectionTitleText(tr.title),
      if (isMobile)
        SectionSwitchListTile(
          secondary: const Icon(Icons.block),
          title: Text(tr.doublePressExit.title),
          subtitle: Text(tr.doublePressExit.detail),
          value: doublePressExit,
          onChanged: (v) async {
            context
                .read<SettingsBloc>()
                .add(SettingsValueChanged(SettingsKeys.doublePressExit, v));
          },
        ),
      SectionSwitchListTile(
        secondary: const Icon(Icons.align_vertical_top),
        title: Text(tr.threadReverseOrder.title),
        subtitle: Text(tr.threadReverseOrder.detail),
        value: threadReverseOrder,
        onChanged: (v) async => context
            .read<SettingsBloc>()
            .add(SettingsValueChanged(SettingsKeys.threadReverseOrder, v)),
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
        leading: const Icon(Icons.emoji_emotions),
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
                SettingsValueChanged(
                  SettingsKeys.checkinFeeling,
                  result,
                  // CheckinFeeling.from(result),
                ),
              );
        },
      ),
      // Message
      SectionListTile(
        leading: const Icon(Icons.textsms),
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
              .add(SettingsValueChanged(SettingsKeys.checkinMessage, result));
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
      SectionListTile(
        leading: const Icon(Icons.cleaning_services),
        title: Text(context.t.settingsPage.storageSection.clearCache),
        onTap: () async {
          await showClearCacheBottomSheet(context: context);
        },
      ),
    ];
  }

  List<Widget> _buildAdvanceSection(
    BuildContext context,
    SettingsState state,
  ) {
    final netClientUseProxy = state.settingsMap.netClientUseProxy;
    final netClientProxy = state.settingsMap.netClientProxy;
    String? host;
    String? port;
    if (netClientProxy.contains(':')) {
      final parts = netClientProxy.split(':');
      host = parts.elementAtOrNull(0);
      port = parts.elementAtOrNull(1);
    }

    final tr = context.t.settingsPage.advancedSection;
    return [
      SectionTitleText(tr.title),
      SectionSwitchListTile(
        secondary: Icon(MdiIcons.networkOutline),
        title: Text(tr.useProxy),
        value: netClientUseProxy,
        onChanged: (v) {
          context.read<SettingsBloc>().add(
                SettingsValueChanged(
                  SettingsKeys.netClientUseProxy,
                  v,
                ),
              );
          showSnackBar(
            context: context,
            message: context.t.general.affectAfterRestart,
          );
        },
      ),
      SectionListTile(
        enabled: netClientUseProxy,
        leading: const Icon(Icons.network_locked),
        title: Text(tr.proxySettings.title),
        subtitle: netClientUseProxy ? null : Text(tr.proxySettings.disabled),
        onTap: () async => showDialog<void>(
          context: context,
          builder: (context) => ProxySettingsDialog(
            host: host,
            port: port,
          ),
          barrierDismissible: false,
        ),
      ),
    ];
  }

  List<Widget> _buildOtherSection(BuildContext context) {
    final tr = context.t.settingsPage.othersSection;
    return [
      SectionTitleText(tr.title),
      // About
      SectionListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(tr.about),
        onTap: () async {
          await context.pushNamed(ScreenPaths.about);
        },
      ),

      /// Update
      SectionListTile(
        leading: const Icon(Icons.new_releases),
        title: Text(tr.upgrade),
        onTap: () async {
          await context.pushNamed(ScreenPaths.upgrade);
        },
      ),

      /// Changelog till publish.
      SectionListTile(
        leading: const Icon(Icons.history),
        title: Text(tr.changelog),
        onTap: () async {
          await showDialog<void>(
            context: context,
            builder: (context) {
              final size = MediaQuery.of(context).size;
              return AlertDialog(
                scrollable: true,
                title: Text(tr.changelog),
                content: SizedBox(
                  width: size.width * 0.7,
                  height: size.height * 0.7,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: Markdown(data: changelogContent),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.t.general.ok),
                  ),
                ],
              );
            },
          );
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
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.t.navigation.settings),
          ),
          body: ListView(
            controller: scrollController,
            children: [
              ..._buildAppearanceSection(context, state),
              ..._buildBehaviorSection(context, state),
              ..._buildCheckinSection(context, state),
              ..._buildStorageSection(context, state),
              ..._buildAdvanceSection(context, state),
              ..._buildOtherSection(context),
            ],
          ),
        );
      },
    );
  }
}
