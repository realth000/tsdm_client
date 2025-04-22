import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/cache/bloc/image_cache_trigger_cubit.dart';
import 'package:tsdm_client/features/cache/repository/image_cache_repository.dart';
import 'package:tsdm_client/features/checkin/bloc/auto_checkin_bloc.dart';
import 'package:tsdm_client/features/checkin/bloc/checkin_bloc.dart';
import 'package:tsdm_client/features/checkin/repository/auto_checkin_repository.dart';
import 'package:tsdm_client/features/checkin/repository/checkin_repository.dart';
import 'package:tsdm_client/features/forum/repository/forum_repository.dart';
import 'package:tsdm_client/features/notification/bloc/auto_notification_cubit.dart';
import 'package:tsdm_client/features/notification/bloc/notification_bloc.dart';
import 'package:tsdm_client/features/notification/bloc/notification_state_auto_sync_cubit.dart';
import 'package:tsdm_client/features/notification/bloc/notification_state_cubit.dart';
import 'package:tsdm_client/features/notification/repository/notification_info_repository.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/features/profile/repository/profile_repository.dart';
import 'package:tsdm_client/features/root/bloc/points_changes_cubit.dart';
import 'package:tsdm_client/features/root/bloc/root_location_cubit.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/features/theme/cubit/theme_cubit.dart';
import 'package:tsdm_client/features/thread_visit_history/bloc/thread_visit_history_bloc.dart';
import 'package:tsdm_client/features/thread_visit_history/repository/thread_visit_history_repository.dart';
import 'package:tsdm_client/features/update/cubit/update_cubit.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/app_routes.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/shared/repositories/fragments_repository/fragments_repository.dart';
import 'package:tsdm_client/themes/app_themes.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:window_manager/window_manager.dart';

/// Main app for tsdm_client.
class App extends StatefulWidget {
  /// Constructor.
  const App(
    this.color,
    this.themeModeIndex, {
    required this.autoCheckin,
    required this.autoSyncNoticeSeconds,
    required this.fontFamily,
    required this.checkUpdate,
    super.key,
  });

  /// Initial color value.
  final int color;

  /// Initial theme mode index.
  final int themeModeIndex;

  /// Run auto checkin at startup or not.
  final bool autoCheckin;

  /// Duration to sync notice from server.
  final int autoSyncNoticeSeconds;

  /// Font family.
  final String fontFamily;

  /// Check update on app startup.
  final bool checkUpdate;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WindowListener, LoggerMixin {
  /// Duration used to debounce the frequency to save window attributes into
  /// storage.
  ///
  /// Only save the latest value to storage if in recent duration no more attr
  /// changes triggered.
  static const _syncDebounceDuration = Duration(milliseconds: 80);

  /// Temporary store of current window position value.
  var _windowPosition = Offset.zero;

  /// Temporary store of current window size value.
  var _windowSize = Size.zero;

  /// Timer to debounce the saving progress of window position.
  ///
  /// Save [_windowPosition] to storage when timer timeout.
  Timer? windowPositionTimer;

  /// Timer to debounce the saving progress of window size.
  ///
  /// Save [_windowSize] to storage when timer timeout.
  Timer? windowSizeTimer;

  void setupWindowPositionTimer() {
    if (windowPositionTimer?.isActive ?? false) {
      windowPositionTimer!.cancel();
    }
    windowPositionTimer = Timer(_syncDebounceDuration, () async {
      talker.debug('save window position to $_windowPosition');
      final settings = getIt.get<SettingsRepository>().currentSettings;
      if (!settings.windowRememberPosition || settings.windowInCenter) {
        // Do nothing if not remembering window position, or window forced in
        // center.
        return;
      }
      // FIXME: Access provider in top-level components is anti-pattern.
      await getIt.get<StorageProvider>().saveOffset(SettingsKeys.windowPosition.name, _windowPosition);
    });
  }

  void setupWindowSizeTimer() {
    if (windowSizeTimer?.isActive ?? false) {
      windowSizeTimer!.cancel();
    }
    windowSizeTimer = Timer(_syncDebounceDuration, () async {
      talker.debug('save window size to $_windowPosition');
      final settings = getIt.get<SettingsRepository>().currentSettings;
      if (!settings.windowRememberSize) {
        // Do nothing if not remembering window size.
        return;
      }
      // FIXME: Access provider in top-level components is anti-pattern.
      await getIt.get<StorageProvider>().saveSize(SettingsKeys.windowSize.name, _windowSize);
    });
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    windowPositionTimer?.cancel();
    windowSizeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<NotificationInfoRepository>(create: (_) => NotificationInfoRepository()),
        RepositoryProvider<NotificationRepository>(create: (_) => NotificationRepository()),
        RepositoryProvider<AuthenticationRepository>(create: (_) => AuthenticationRepository()),
        RepositoryProvider<CheckinRepository>(create: (_) => CheckinRepository(storageProvider: getIt())),
        RepositoryProvider<ForumHomeRepository>(create: (_) => ForumHomeRepository()),
        RepositoryProvider<ProfileRepository>(create: (_) => ProfileRepository()),
        RepositoryProvider<FragmentsRepository>(create: (_) => FragmentsRepository()),
        RepositoryProvider<ForumRepository>(create: (_) => ForumRepository()),
        RepositoryProvider<ImageCacheRepository>(create: (_) => ImageCacheRepository(getIt())),
        RepositoryProvider<ImageCacheTriggerCubit>(create: (context) => ImageCacheTriggerCubit(context.repo())),
        RepositoryProvider<ThreadVisitHistoryRepo>(create: (_) => ThreadVisitHistoryRepo(getIt.get<StorageProvider>())),
        RepositoryProvider<AutoCheckinRepository>(create: (_) => AutoCheckinRepository(storageProvider: getIt())),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => NotificationStateAutoSyncCubit(context.repo())),
          BlocProvider(
            create: (_) => RootLocationCubit(),
            // Set lazy to false to react on first location change.
            lazy: false,
          ),
          BlocProvider(create: (context) => NotificationStateCubit(context.repo())),
          BlocProvider(
            create: (context) {
              final bloc = AutoNotificationCubit(
                authenticationRepository: context.repo(),
                notificationRepository: context.repo(),
                storageProvider: getIt(),
              );
              if (widget.autoSyncNoticeSeconds > 0) {
                bloc.start(Duration(seconds: widget.autoSyncNoticeSeconds));
              }
              return bloc;
            },
          ),
          BlocProvider(
            create:
                (context) => NotificationBloc(
                  notificationRepository: context.repo(),
                  infoRepository: context.repo(),
                  authRepo: context.repo(),
                  storageProvider: getIt(),
                ),
          ),
          BlocProvider(
            create:
                (context) => SettingsBloc(
                  fragmentsRepository: context.repo(),
                  settingsRepository: getIt.get<SettingsRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) => ThreadVisitHistoryBloc(context.repo())..add(const ThreadVisitHistoryFetchAllRequested()),
          ),
          // Become top-level because of background auto-checkin feature.
          BlocProvider(
            create:
                (context) => CheckinBloc(
                  checkinRepository: context.repo(),
                  authenticationRepository: context.repo(),
                  settingsRepository: getIt(),
                ),
          ),
          BlocProvider(
            create: (context) {
              final bloc = AutoCheckinBloc(
                autoCheckinRepository: context.repo(),
                settingsRepository: getIt(),
                storageProvider: getIt(),
              );
              if (widget.autoCheckin) {
                bloc.add(const AutoCheckinStartRequested());
              }
              return bloc;
            },
          ),
          BlocProvider(
            create:
                (context) => ThemeCubit(
                  accentColor: widget.color >= 0 ? Color(widget.color) : null,
                  themeModeIndex: widget.themeModeIndex,
                  fontFamily: widget.fontFamily,
                ),
          ),
          BlocProvider(
            create: (context) {
              final cubit = UpdateCubit();
              if (widget.checkUpdate) {
                cubit.checkUpdate(delay: const Duration(seconds: 1));
              }
              return cubit;
            },
          ),
          BlocProvider(create: (_) => PointsChangesCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          buildWhen: (prev, curr) => prev != curr,
          builder: (context, state) {
            final themeState = context.watch<ThemeCubit>().state;
            final accentColor = themeState.accentColor;
            final themeModeIndex = themeState.themeModeIndex;
            final fontFamily = themeState.fontFamily;

            final lightTheme = AppTheme.makeLight(context, seedColor: accentColor, fontFamily: fontFamily);
            final darkTheme = AppTheme.makeDark(context, seedColor: accentColor, fontFamily: fontFamily);

            return MaterialApp.router(
              title: context.t.appName,
              routerConfig: router,
              locale: TranslationProvider.of(context).flutterLocale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: ThemeMode.values[themeModeIndex],
            );
          },
        ),
      ),
    );
  }

  @override
  Future<void> onWindowMove() async {
    super.onWindowMove();
    if (isDesktop && !cmdArgs.noWindowChangeRecords) {
      _windowPosition = await windowManager.getPosition();
      setupWindowPositionTimer();
    }
  }

  @override
  Future<void> onWindowResize() async {
    super.onWindowResize();
    if (isDesktop && !cmdArgs.noWindowChangeRecords) {
      _windowSize = await windowManager.getSize();
      setupWindowSizeTimer();
    }
  }
}
