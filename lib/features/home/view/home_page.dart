import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/root/bloc/root_location_cubit.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/widgets/indicator.dart';

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
    unawaited(rootLocationSub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Translations.of(context);

    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => HomeCubit())],
      child: BlocBuilder<InitCubit, InitState>(
        builder: (context, state) {
          if (state.clearingOutdatedImageCache) {
            return const CenteredCircularIndicator();
          }

          if (ResponsiveBreakpoints.of(context).largerThan(WindowSize.expanded.name)) {
            return _buildDrawerBody(context);
          } else if (ResponsiveBreakpoints.of(context).largerThan(WindowSize.compact.name)) {
            return Scaffold(
              body: Row(
                children: [
                  if (widget.showNavigationBar) const HomeNavigationRail(),
                  Expanded(child: widget.child),
                ],
              ),
            );
          } else {
            return Scaffold(
              body: widget.child,
              bottomNavigationBar: widget.showNavigationBar ? const HomeNavigationBar() : null,
            );
          }
        },
      ),
    );
  }
}
