import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'providers/settings_provider.dart';
import 'routes/app_routes.dart';
import 'themes/app_themes.dart';
import 'utils/platform.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSettings();
  if (isDesktop) {
    await _initWindow();
  }
  runApp(const TClientApp());
}

/// Main app.
class TClientApp extends StatelessWidget {
  /// Constructor.
  const TClientApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => ProviderScope(
        child: MaterialApp.router(
          title: 'TSDM Client',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: tClientRouter,
          // TODO: Actually we are using the [TClientScaffold] inside every page.
          // Maybe can do something to this duplicate scaffold.
          builder: (context, child) => Scaffold(body: child),
        ),
      );
}

/// Setup main window settings including size and position.
///
/// If window is set to be in center, ignore position,
Future<void> _initWindow() async {
  await windowManager.ensureInitialized();
  final settings = ProviderContainer();
  final center = settings.read(settingsProvider).windowInCenter;
  // Only apply window position when not set in center.
  if (!center) {
    await windowManager.setPosition(
      Offset(
        settings.read(settingsProvider).windowPositionDx,
        settings.read(settingsProvider).windowPositionDy,
      ),
    );
  }
  await windowManager.waitUntilReadyToShow(
      WindowOptions(
        size: Size(
          settings.read(settingsProvider).windowWidth,
          settings.read(settingsProvider).windowHeight,
        ),
        center: center,
      ), () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
