import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/home/cubit/home_cubit.dart';
import 'package:tsdm_client/features/home/cubit/init_cubit.dart';
import 'package:tsdm_client/features/home/widgets/widgets.dart';
import 'package:tsdm_client/features/local_notice/keys.dart';
import 'package:tsdm_client/features/local_notice/stream.dart';
import 'package:tsdm_client/features/notification/bloc/notification_state_auto_sync_cubit.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/root/bloc/root_location_cubit.dart';
import 'package:tsdm_client/features/root/models/models.dart';
import 'package:tsdm_client/features/root/stream/root_location_stream.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/utils/show_toast.dart';

const _drawerWidth = 250.0;

/// Page of the homepage of the app.
class HomePage extends StatefulWidget {
  /// Constructor.
  const HomePage({required this.showNavigationBar, required this.child, super.key});

  /// Control to show the app level navigation bar or not.
  ///
  /// Only show in top pages.
  final bool showNavigationBar;

  /// Child widget, or call it the body widget.
  final Widget child;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with LoggerMixin {
  /// Use this duration to limit the confirm time between the first exit app
  /// attempt and second real exit action.
  ///
  /// Maximum allowed duration between last time pop action triggered and
  /// current time.
  ///
  /// Means that if the user stayed more than this duration between two pop
  /// navigate action, the second one will be the confirm one and not pop back.
  static const exitConfirmDuration = Duration(seconds: 3);

  /// Record last time user try to exit the app.
  DateTime? lastPopTime;

  /// Location stream subscription.
  late final StreamSubscription<String?> rootLocationSub;

  Future<void> exitApp() async {
    await getIt.get<StorageProvider>().dispose();
    // Close the app.
    if (isAndroid || isIOS) {
      await SystemNavigator.pop(animated: true);
    } else {
      // CAUTION: unsafe operation.
      exit(0);
    }
  }

  Future<void> _onLocalNoticeStreamEvent(String? payload) async {
    switch (payload) {
      case LocalNoticeKeys.openNotification:
        if (context.read<AuthenticationRepository>().currentUser == null) {
          debug('refuse to push to unavailable notification page: need login');
          return;
        }

        if (context.read<RootLocationCubit>().isIn(ScreenPaths.notice)) {
          debug('do not push to notice page already in it');
        } else {
          debug('push to notice page already in it');
          await context.pushNamed(ScreenPaths.notice);
        }
    }
  }

  Widget _buildDrawerBody(BuildContext context) => Scaffold(
    body: Row(
      children: [
        if (widget.showNavigationBar)
          Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
                height: 100,
                width: _drawerWidth,
                child: Center(
                  child: Text(
                    context.t.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _drawerWidth),
                  child: const HomeNavigationDrawer(),
                ),
              ),
            ],
          ),
        Expanded(child: widget.child),
      ],
    ),
  );

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
    rootLocationSub = localNoticeStream.stream.listen(_onLocalNoticeStreamEvent);
  }

  @override
  void dispose() {
    rootLocationSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Translations.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeCubit()),
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
            return cubit;
          },
        ),
      ],
      child: MultiBlocListener(
        listeners: [
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
        child: BlocBuilder<InitCubit, InitState>(
          builder: (context, state) {
            if (state.clearingOutdatedImageCache) {
              return const Center(child: CircularProgressIndicator());
            }

            final Widget child;
            if (ResponsiveBreakpoints.of(context).largerThan(WindowSize.expanded.name)) {
              child = _buildDrawerBody(context);
            } else if (ResponsiveBreakpoints.of(context).largerThan(WindowSize.compact.name)) {
              child = Scaffold(
                body: Row(
                  children: [
                    if (widget.showNavigationBar) const HomeNavigationRail(),
                    Expanded(child: widget.child),
                  ],
                ),
              );
            } else {
              child = Scaffold(
                body: widget.child,
                bottomNavigationBar: widget.showNavigationBar ? const HomeNavigationBar() : null,
              );
            }

            // The global listener handles app-wide leave page events.
            // Every time user intended to leave a certain page, `lastRequestLeavePageTime` is updated and this
            // listener process check for leave event, decide the page can be popped or not.
            //
            // The logic here is to implements double-press before exit app feature. All popping page events are
            // intercepted by the `BackButtonListener` below, it only triggers the update of `lastRequestLeavePageTime`,
            // which notifies this listener.
            //
            // Every time the pop is allowed, update page locations in `RootLocationCubit` by adding
            // `RootLocationEventLeave` to stream.
            return BlocListener<RootLocationCubit, RootLocationState>(
              listenWhen: (prev, curr) => prev.lastRequestLeavePageTime != curr.lastRequestLeavePageTime,
              listener: (context, state) async {
                // Check if fine to pop the current page.
                final location = state.locations.lastOrNull;
                if (location != ScreenPaths.homepage &&
                    location != ScreenPaths.topic &&
                    location != ScreenPaths.settings.path &&
                    location != null) {
                  // Popping current page will not close the app, allow to pop.
                  rootLocationStream.add(RootLocationEventLeave(location));
                  return context.pop();
                }

                // Check for double press exit feature.
                // From here, if we intend to pop the page, in fact we shall exit the app.

                final doublePressExit = getIt.get<SettingsRepository>().currentSettings.doublePressExit;
                if (!doublePressExit) {
                  // Double-press before exit feature is disabled, exit app.
                  await exitApp();
                  return;
                }

                // From here, double-press before exit feature is enabled.

                final tr = context.t.home;
                final currentTime = DateTime.now();
                if (lastPopTime == null ||
                    currentTime.difference(lastPopTime!).inMilliseconds > exitConfirmDuration.inMilliseconds) {
                  lastPopTime = currentTime;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  showSnackBar(context: context, message: tr.confirmExit);
                  // Require the second pop event.
                  return;
                }

                // A second pop event is here, exit app.
                await exitApp();
                // Unreachable
                return;
              },
              child: BackButtonListener(
                onBackButtonPressed: () async {
                  // App wide popping events interceptor, handles all popping events and notify the listener above.
                  rootLocationStream.add(const RootLocationEventLeavingLast());
                  if (!context.mounted) {
                    // Well, leave it here.
                    await exitApp();
                    return true;
                  }
                  return true;
                },
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}
