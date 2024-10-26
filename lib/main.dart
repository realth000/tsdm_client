import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:system_theme/system_theme.dart';
import 'package:tsdm_client/app.dart';
import 'package:tsdm_client/cmd.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/providers.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/utils/window_configs.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main(List<String> args) async {
  parseCmdArgs(args);

  talker.debug('start app...');
  WidgetsFlutterBinding.ensureInitialized();
  await initProviders();

  final settings = getIt.get<SettingsRepository>().currentSettings;

  final settingsLocale = settings.locale;
  final locale =
      AppLocale.values.firstWhereOrNull((v) => v.languageTag == settingsLocale);
  if (locale == null) {
    await LocaleSettings.useDeviceLocale();
  } else {
    await LocaleSettings.setLocale(locale);
  }

  if (isDesktop) {
    await windowManager.ensureInitialized();
    if (!cmdArgs.noWindowConfigs) {
      await desktopUpdateWindowTitle();
      if (settings.windowInCenter) {
        await windowManager.center();
      } else if (settings.windowRememberPosition &&
          settings.windowPosition != Offset.zero) {
        await windowManager.setPosition(settings.windowPosition);
      }
      if (settings.windowRememberSize && settings.windowSize != Size.zero) {
        await windowManager.setSize(settings.windowSize);
      }
    }
  }

  // System color.
  // Use this color when following system color settings turned on.
  //
  // A not empty value represents currently is using system color and the color
  // value is inside it.
  final useSystemTheme = settings.accentColorFollowSystem;

  final color = switch (useSystemTheme) {
    true => await SystemTheme.accentColor
        .load()
        .then((_) => SystemTheme.accentColor.accent.value),
    false => settings.accentColor,
  };
  final themeModeIndex = settings.themeMode;

  final autoCheckin = settings.autoCheckin;

  runApp(
    TranslationProvider(
      child: ResponsiveBreakpoints.builder(
        breakpoints: WindowSize.values
            .map((e) => Breakpoint(start: e.start, end: e.end, name: e.name))
            .toList(),
        child: App(color, themeModeIndex, autoCheckin: autoCheckin),
      ),
    ),
  );
}
