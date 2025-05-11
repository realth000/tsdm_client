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
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/utils/show_toast.dart';

const _drawerWidth = 250.0;

/// Page of the homepage of the app.
class HomePage extends StatefulWidget {
  /// Constructor.
  const HomePage({
    required ForumHomeRepository forumHomeRepository,
    required this.showNavigationBar,
    required this.child,
    super.key,
  }) : _forumHomeRepository = forumHomeRepository;

  /// Control to show the app level navigation bar or not.
  ///
  /// Only show in top pages.
  final bool showNavigationBar;

  /// Child widget, or call it the body widget.
  final Widget child;

  final ForumHomeRepository _forumHomeRepository;

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

  Widget _buildContent(BuildContext context) {
    final Widget child;
    if (ResponsiveBreakpoints.of(context).largerThan(WindowSize.expanded.name)) {
      child = _buildDrawerBody(context);
    } else if (ResponsiveBreakpoints.of(context).largerThan(WindowSize.compact.name)) {
      child = Scaffold(
        body: Row(children: [if (widget.showNavigationBar) const HomeNavigationRail(), Expanded(child: widget.child)]),
      );
    } else {
      child = Scaffold(
        body: widget.child,
        bottomNavigationBar: widget.showNavigationBar ? const HomeNavigationBar() : null,
      );
    }

    return RepositoryProvider.value(
      value: widget._forumHomeRepository,
      child: BackButtonListener(
        onBackButtonPressed: () async {
          final doublePressExit = getIt.get<SettingsRepository>().currentSettings.doublePressExit;
          if (!doublePressExit) {
            // Do NOT handle pop events on double press check is disabled.
            return false;
          }
          if (!context.mounted) {
            return false;
          }
          final location = context.read<RootLocationCubit>().current;
          if (location != ScreenPaths.homepage &&
              location != ScreenPaths.topic &&
              location != ScreenPaths.settings.path) {
            // Do NOT handle pop events on other pages.
            return false;
          }
          final tr = context.t.home;
          final currentTime = DateTime.now();
          if (lastPopTime == null ||
              currentTime.difference(lastPopTime!).inMilliseconds > exitConfirmDuration.inMilliseconds) {
            lastPopTime = currentTime;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            showSnackBar(context: context, message: tr.confirmExit);
            return true;
          }
          // Close the app.
          if (isAndroid || isIOS) {
            await SystemNavigator.pop(animated: true);
          } else {
            // CAUTION: unsafe operation.
            exit(0);
          }
          // Unreachable
          return false;
        },
        child: child,
      ),
    );
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
      NotificationAutoSyncInfoNotice(:final msg, :final notice, :final personalMessage, :final broadcastMessage) => tr
          .notice
          .detail
          .notice(noticeCount: notice, pmCount: personalMessage, bmCount: broadcastMessage, msg: msg),
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
      NotificationAutoSyncInfoBm(:final msg, :final notice, :final personalMessage, :final broadcastMessage) => tr
          .notice
          .detail
          .bm(noticeCount: notice, pmCount: personalMessage, bmCount: broadcastMessage, msg: msg),
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
        BlocProvider(create: (context) => InitCubit()..deleteV0LegacyData()),
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
        child: _buildContent(context),
      ),
    );
  }
}
