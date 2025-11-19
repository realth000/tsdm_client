import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:system_theme/system_theme.dart';
import 'package:tsdm_client/app.dart';
import 'package:tsdm_client/cmd.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/color.dart';
import 'package:tsdm_client/features/local_notice/callback.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/providers.dart';
import 'package:tsdm_client/shared/providers/proxy_provider/proxy_provider.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/utils/window_configs.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main(List<String> args) async => runZonedGuarded(() async => _boot(args), _ensureHandled);

Future<void> _boot(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await initLogger();

  parseCmdArgs(args);

  talker.debug('------------------- start app -------------------');
  await initProviders();

  // 初始化后台服务
  await BackgroundService.initialize();
  
  // 获取设置仓库并检查后台常驻设置
  final settingsRepo = getIt.get<SettingsRepository>();
  final backgroundKeepAliveEnabled = settingsRepo.currentSettings.backgroundKeepAlive ?? false;
  
  // 如果设置中启用了后台常驻，则启动后台任务
  if (backgroundKeepAliveEnabled) {
    await BackgroundService.startBackgroundTask();
  }
  
  final settings = getIt.get<SettingsRepository>().currentSettings;

  final settingsLocale = settings.locale;
  final locale = AppLocale.values.firstWhereOrNull((v) => v.languageTag == settingsLocale);
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
      } else if (settings.windowRememberPosition && settings.windowPosition != Offset.zero) {
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
    true => await SystemTheme.accentColor.load().then((_) => SystemTheme.accentColor.accent.valueA),
    false => settings.accentColor,
  };
  final themeModeIndex = settings.themeMode;

  final autoCheckin = settings.autoCheckin;
  final autoSyncNoticeSeconds = settings.autoSyncNoticeSeconds;

  // Initialize flutter_local_notification.
  flnp = FlutterLocalNotificationsPlugin();
  if (isAndroid) {
    await flnp.initialize(
      // Drawable ic_launcher_foreground_no_transform is shrunk when building in CI.
      // The default one is compat but ok.
      const InitializationSettings(android: AndroidInitializationSettings('@drawable/ic_launcher_foreground')),
      onDidReceiveNotificationResponse: onLocalNotificationOpened,
    );
    if (autoSyncNoticeSeconds > 0) {
      await flnp
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  // Load font family.
  final fontFamily = settings.fontFamily;

  // Check update when app startup.
  final checkUpdate = settings.enableUpdateCheckOnStartup;

  // Only record system proxy settings if required to do so.
  if (settings.useDetectedProxyWhenStartup) {
    await getIt.get<ProxyProvider>().updateProxy();
  }

  runApp(
    TranslationProvider(
      child: ResponsiveBreakpoints.builder(
        breakpoints: WindowSize.values.map((e) => Breakpoint(start: e.start, end: e.end, name: e.name)).toList(),
        child: App(
          color,
          themeModeIndex,
          autoCheckin: autoCheckin,
          autoSyncNoticeSeconds: autoSyncNoticeSeconds,
          fontFamily: fontFamily,
          checkUpdate: checkUpdate,
        ),
      ),
    ),
  );
}

void _ensureHandled(Object exception, StackTrace? stackTrace) => talker.handle(exception, stackTrace);
