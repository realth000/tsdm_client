import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/cache/bloc/image_cache_trigger_cubit.dart';
import 'package:tsdm_client/features/cache/repository/image_cache_repository.dart';
import 'package:tsdm_client/features/checkin/bloc/auto_checkin_bloc.dart';
import 'package:tsdm_client/features/checkin/bloc/checkin_bloc.dart';
import 'package:tsdm_client/features/checkin/repository/auto_checkin_repository.dart';
import 'package:tsdm_client/features/checkin/repository/checkin_repository.dart';
import 'package:tsdm_client/features/forum/repository/forum_repository.dart';
import 'package:tsdm_client/features/home/cubit/init_cubit.dart';
import 'package:tsdm_client/features/local_notice/keys.dart';
import 'package:tsdm_client/features/notification/bloc/auto_notification_cubit.dart';
import 'package:tsdm_client/features/notification/bloc/notification_bloc.dart';
import 'package:tsdm_client/features/notification/bloc/notification_state_auto_sync_cubit.dart';
import 'package:tsdm_client/features/notification/bloc/notification_state_cubit.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/notification/repository/notification_info_repository.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/features/profile/repository/profile_repository.dart';
import 'package:tsdm_client/features/root/bloc/points_changes_cubit.dart';
import 'package:tsdm_client/features/root/bloc/root_location_cubit.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/features/theme/cubit/theme_cubit.dart';
import 'package:tsdm_client/features/thread_visit_history/bloc/thread_visit_history_bloc.dart';
import 'package:tsdm_client/features/thread_visit_history/repository/thread_visit_history_repository.dart';
import 'package:tsdm_client/features/update/cubit/update_cubit.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/app_routes.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/shared/repositories/fragments_repository/fragments_repository.dart';
import 'package:tsdm_client/themes/app_themes.dart';
import 'package:tsdm_client/utils/git_info.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';
import 'package:window_manager/window_manager.dart';

extension _SignedInteger on int {
  String withSign() => this < 0
      ? '$this'
      : this > 0
      ? '+$this'
      : '0';
}

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

  /// The same value in flutter/lib/src/material/snack_bar.dart;
  static const Duration _snackBarDisplayDuration = Duration(milliseconds: 4000 - 1000);

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

  Future<void> showLocalNotification(BuildContext context, NotificationAutoSyncInfo info) async {
    final tr = context.t.localNotification;
    final and = AndroidNotificationDetails(
      'newNoticeChannel',
      tr.channelName,
      channelDescription: tr.channelDesc,
      ticker: tr.ticker,
    );
    final nd = NotificationDetails(android: and);
    final noticeData = switch (info) {
      NotificationAutoSyncInfoNotice(:final msg, :final notice, :final personalMessage, :final broadcastMessage) =>
        tr.notice.detail.notice(noticeCount: notice, pmCount: personalMessage, bmCount: broadcastMessage, msg: msg),
      NotificationAutoSyncInfoPm(
        :final user,
        :final msg,
        :final notice,
        :final personalMessage,
        :final broadcastMessage,
      ) =>
        tr.notice.detail.pm(
          noticeCount: notice,
          pmCount: personalMessage,
          bmCount: broadcastMessage,
          user: user,
          msg: msg,
        ),
      NotificationAutoSyncInfoBm(:final msg, :final notice, :final personalMessage, :final broadcastMessage) =>
        tr.notice.detail.bm(noticeCount: notice, pmCount: personalMessage, bmCount: broadcastMessage, msg: msg),
    };
    if (isAndroid) {
      await flnp.show(0, tr.notice.title, noticeData, nd, payload: LocalNoticeKeys.openNotification);
    }
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
    final tr = context.t.globalStatePage;

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
            create: (context) => NotificationBloc(
              notificationRepository: context.repo(),
              infoRepository: context.repo(),
              authRepo: context.repo(),
              storageProvider: getIt(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                SettingsBloc(fragmentsRepository: context.repo(), settingsRepository: getIt.get<SettingsRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                ThreadVisitHistoryBloc(context.repo())..add(const ThreadVisitHistoryFetchAllRequested()),
          ),
          // Become top-level because of background auto-checkin feature.
          BlocProvider(
            create: (context) => CheckinBloc(
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
            create: (context) => ThemeCubit(
              accentColor: widget.color >= 0 ? Color(widget.color) : null,
              themeModeIndex: widget.themeModeIndex,
              fontFamily: widget.fontFamily,
            ),
          ),
          BlocProvider(
            create: (context) {
              final cubit = UpdateCubit();
              if (widget.checkUpdate) {
                cubit.checkUpdate(delay: const Duration(seconds: 1), notice: false);
              }
              return cubit;
            },
          ),
          BlocProvider(create: (_) => PointsChangesCubit()),
          BlocProvider(
            create: (context) {
              final settings = context.read<SettingsBloc>().state.settingsMap;

              final cubit = InitCubit();
              unawaited(cubit.deleteV0LegacyData());
              if (settings.enableAutoClearImageCache) {
                cubit.autoClearImageCache(Duration(seconds: settings.autoClearImageCacheDuration));
              } else {
                cubit.skipAutoClearImageCache();
              }
              cubit.autoClearFilePickerCache();
              return cubit;
            },
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<AutoCheckinBloc, AutoCheckinState>(
              listenWhen: (prev, curr) => prev is! AutoCheckinStateFinished && curr is AutoCheckinStateFinished,
              listener: (context, state) {
                if (state is AutoCheckinStateFinished) {
                  showSnackBar(
                    context: context,
                    message: tr.autoCheckinFinished,
                    action: SnackBarAction(
                      label: tr.viewDetail,
                      onPressed: () async => context.pushNamed(ScreenPaths.autoCheckinDetail),
                    ),
                  );
                }
              },
            ),
            BlocListener<NotificationBloc, NotificationState>(
              listener: (context, state) {
                if (state.status == NotificationStatus.loading) {
                  final autoSyncState = context.read<AutoNotificationCubit>();
                  if (autoSyncState.state is AutoNoticeStateTicking) {
                    // Restart the auto notification sync process.
                    context.read<AutoNotificationCubit>().restart();
                  }
                } else if (state.status == NotificationStatus.success) {
                  // Update last fetch notification time.
                  // We do it here because it's a global action lives in the entire lifetime of the app, not only when
                  // the notification page is live. This fixes the critical issue where time not updated.
                  if (state.latestTime != null) {
                    context.read<NotificationBloc>().add(NotificationRecordFetchTimeRequested(state.latestTime!));
                  }
                }
              },
            ),
            BlocListener<UpdateCubit, UpdateCubitState>(
              listenWhen: (prev, curr) => curr.loading == false && prev.loading == true,
              listener: (context, state) async {
                final info = state.latestVersionInfo;
                final tr = context.t.updatePage;
                if (info == null) {
                  error('failed to check update state');
                  if (state.notice) {
                    showSnackBar(context: context, message: tr.failed);
                  }
                  return;
                }

                final inUpdatePage = context.read<RootLocationCubit>().isIn(ScreenPaths.update);

                if (info.versionCode <= appVersion.split('+').last.parseToInt()!) {
                  // Only show the already latest message in update page.
                  if (inUpdatePage) {
                    showSnackBar(context: context, message: tr.alreadyLatest);
                  }
                } else {
                  final gotoUpdatePage = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      final size = MediaQuery.sizeOf(context);
                      return RootPage(
                        DialogPaths.updateNotice,
                        CustomAlertDialog.sync(
                          title: Text(tr.availableDialog.title),
                          content: SizedBox(
                            width: math.min(size.width * 0.8, 800),
                            height: math.min(size.height * 0.6, 600),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr.availableDialog.version(version: info.version),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                                ),
                                sizedBoxW8H8,
                                Expanded(child: Markdown(data: info.changelog)),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(child: Text(context.t.general.cancel), onPressed: () => context.pop(false)),
                            TextButton(
                              child: Text(context.t.settingsPage.othersSection.update),
                              onPressed: () => context.pop(true),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                  if (true == gotoUpdatePage && context.mounted && !inUpdatePage) {
                    await context.pushNamed(ScreenPaths.update);
                  }
                }
              },
            ),
            BlocListener<PointsChangesCubit, PointsChangesValue>(
              listenWhen: (prev, curr) => prev != curr && curr != PointsChangesValue.empty,
              listener: (context, state) {
                final tr = context.t.pointsChangesDialog;

                final kinds = <String>[];
                if (state.ww != 0) {
                  kinds.add(tr.points.ww(value: state.ww.withSign()));
                }
                if (state.tsb != 0) {
                  kinds.add(tr.points.tsb(value: state.tsb.withSign()));
                }
                if (state.xc != 0) {
                  kinds.add(tr.points.xc(value: state.xc.withSign()));
                }
                if (state.tr != 0) {
                  kinds.add(tr.points.tr(value: state.tr.withSign()));
                }
                if (state.fh != 0) {
                  kinds.add(tr.points.fh(value: state.fh.withSign()));
                }
                if (state.jl != 0) {
                  kinds.add(tr.points.jl(value: state.jl.withSign()));
                }
                if (state.specialAttr != 0) {
                  kinds.add(tr.points.specialAttr(value: state.specialAttr.withSign()));
                }
                showToast(
                  kinds.join(tr.sep),
                  context: context,
                  duration: _snackBarDisplayDuration,
                  position: const StyledToastPosition(align: Alignment.topCenter, offset: kToolbarHeight),
                  textStyle: Theme.of(context).snackBarTheme.contentTextStyle,
                  backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
                );
              },
            ),
            BlocListener<NotificationStateAutoSyncCubit, NotificationAutoSyncInfo?>(
              listenWhen: (prev, curr) => curr != null && prev != curr,
              listener: (context, state) async {
                await showLocalNotification(context, state!);
              },
            ),
            BlocListener<InitCubit, InitState>(
              listenWhen: (prev, curr) => prev.v0LegacyDataDeleted != curr.v0LegacyDataDeleted,
              listener: (context, state) {
                if (state.v0LegacyDataDeleted != true) {
                  return;
                }
                final tr = context.t.init.v1DeleteLegacyData;
                showMessageSingleButtonDialog(context: context, title: tr.title, message: tr.detail);
              },
            ),
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
                scaffoldMessengerKey: snackbarKey,
              );
            },
          ),
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
