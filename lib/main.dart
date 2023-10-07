import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/settings_provider.dart';
import 'package:tsdm_client/routes/app_routes.dart';
import 'package:tsdm_client/themes/app_themes.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSettings();
  if (isDesktop) {
    await _initWindow();
  }
  runApp(const ProviderScope(
    child: TClientApp(),
  ));
}

/// Main app.
class TClientApp extends ConsumerWidget {
  /// Constructor.
  const TClientApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'TSDM Client',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.values[ref.watch(appSettingsProvider).themeMode],
      routerConfig: tClientRouter,
      // TODO: Actually we are using the [TClientScaffold] inside every page.
      // Maybe can do something to this duplicate scaffold.
      builder: (context, child) => Scaffold(body: child),
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
