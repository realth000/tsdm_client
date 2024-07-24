import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tsdm_client/app.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/providers.dart';
import 'package:tsdm_client/shared/providers/settings_provider/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bloc.observer = const Observer();
  await initProviders();
  // await BBCodeEditor.initialize();

  final settingsLocale = getIt.get<SettingsProvider>().getLocale();
  final locale =
      AppLocale.values.firstWhereOrNull((v) => v.languageTag == settingsLocale);
  if (locale == null) {
    LocaleSettings.useDeviceLocale();
  } else {
    LocaleSettings.setLocale(locale);
  }

  runApp(
    TranslationProvider(
      child: ResponsiveBreakpoints.builder(
        breakpoints: WindowSize.values
            .map((e) => Breakpoint(start: e.start, end: e.end, name: e.name))
            .toList(),
        child: const App(),
      ),
    ),
  );
}
