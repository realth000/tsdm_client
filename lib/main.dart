import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_framework/breakpoint.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/settings_provider.dart';
import 'package:tsdm_client/providers/storage_provider.dart';
import 'package:tsdm_client/routes/app_routes.dart';
import 'package:tsdm_client/themes/app_themes.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initStorage();
  // FIXME: Do not use ProviderContainer.
  final settingsLocale = ProviderContainer().read(appSettingsProvider).locale;
  final locale =
      AppLocale.values.firstWhereOrNull((v) => v.languageTag == settingsLocale);
  if (locale == null) {
    LocaleSettings.useDeviceLocale();
  } else {
    LocaleSettings.setLocale(locale);
  }

  if (isDesktop) {
    await _initWindow();
  }
  runApp(
    TranslationProvider(
      child: ResponsiveBreakpoints.builder(
        breakpoints: const [
          Breakpoint(start: 0, end: 450, name: MOBILE),
          Breakpoint(start: 451, end: 800, name: TABLET),
          Breakpoint(start: 801, end: 1920, name: DESKTOP),
          Breakpoint(start: 1921, end: double.infinity, name: '4k'),
          Breakpoint(start: 650, end: 650, name: 'homepage_welcome_expand'),
          Breakpoint(start: 900, end: 900, name: 'app_expand_side_panel'),
        ],
        child: const ProviderScope(child: TClientApp()),
      ),
    ),
  );
}

/// Main app.
class TClientApp extends ConsumerWidget {
  /// Constructor.
  const TClientApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: context.t.appName,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.values[ref.watch(appSettingsProvider).themeMode],
      routerConfig: tClientRouter,
    );
  }
}

/// Setup main window settings including size and position.
///
/// If window is set to be in center, ignore position,
Future<void> _initWindow() async {
  await windowManager.ensureInitialized();
  final settings = ProviderContainer();
  final center = settings.read(appSettingsProvider).windowInCenter;
  // Only apply window position when not set in center.
  if (!center) {
    await windowManager.setPosition(
      Offset(
        settings.read(appSettingsProvider).windowPositionDx,
        settings.read(appSettingsProvider).windowPositionDy,
      ),
    );
  }
  await windowManager.waitUntilReadyToShow(
      WindowOptions(
        size: Size(
          settings.read(appSettingsProvider).windowWidth,
          settings.read(appSettingsProvider).windowHeight,
        ),
        center: center,
      ), () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
