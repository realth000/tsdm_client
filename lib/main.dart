import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tsdm_client/app.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bloc.observer = const Observer();
  await initProviders();
  // await BBCodeEditor.initialize();

  final settings = getIt.get<SettingsRepository>();

  final settingsLocale = await settings.getValue<String>(SettingsKeys.locale);
  final locale =
      AppLocale.values.firstWhereOrNull((v) => v.languageTag == settingsLocale);
  if (locale == null) {
    LocaleSettings.useDeviceLocale();
  } else {
    LocaleSettings.setLocale(locale);
  }

  final color = await settings.getValue<int>(SettingsKeys.accentColor);
  final themeModeIndex = await settings.getValue<int>(SettingsKeys.themeMode);

  runApp(
    TranslationProvider(
      child: ResponsiveBreakpoints.builder(
        breakpoints: WindowSize.values
            .map((e) => Breakpoint(start: e.start, end: e.end, name: e.name))
            .toList(),
        child: const App(color, themeModeIndex),
      ),
    ),
  );
}
