import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/checkin/bloc/auto_checkin_bloc.dart';
import 'package:tsdm_client/features/notification/bloc/auto_notification_cubit.dart';
import 'package:tsdm_client/features/notification/bloc/notification_bloc.dart';
import 'package:tsdm_client/features/points/stream.dart';
import 'package:tsdm_client/features/root/bloc/points_changes_cubit.dart';
import 'package:tsdm_client/features/root/bloc/root_location_cubit.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/features/update/cubit/update_cubit.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/git_info.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// The app wide singleton stands on top of all other pages to act on different events in app.
class RootSingleton extends StatefulWidget {
  /// Constructor.
  const RootSingleton({super.key});

  @override
  State<RootSingleton> createState() => _RootSingletonState();
}

class _RootSingletonState extends State<RootSingleton> with LoggerMixin {
  late final StreamSubscription<String> _pointsChangesSub;

  /// The same value in flutter/lib/src/material/snack_bar.dart;
  static const Duration _snackBarDisplayDuration = Duration(milliseconds: 4000 - 1000);

  /// Act on points changes events.
  ///
  /// Each event is expected to be a string holding what and how points were changed. The data is separated by 'D' with
  /// order:
  ///
  /// 1. UNKNOWN
  /// 2. ww
  /// 3. tsb
  /// 4. xc
  /// 5. tf
  /// 6. ft
  /// 7. jl
  /// 8. Special points changes over time.
  /// 9. UNKNOWN
  /// 10. UID or '0' value. (not used).
  void _onPointsChanges(String event) {
    final segments = event.split('D');
    if (segments.length != 10) {
      info('ignore invalid points changes event, incorrect segments count: "$event"');
      return;
    }

    final ww = segments.elementAt(1).parseToInt();
    final tsb = segments.elementAt(2).parseToInt();
    final xc = segments.elementAt(3).parseToInt();
    final tr = segments.elementAt(4).parseToInt();
    final fh = segments.elementAt(5).parseToInt();
    final jl = segments.elementAt(6).parseToInt();
    final specialAttr = segments.elementAt(7).parseToInt();

    if (ww == null || tsb == null || xc == null || tr == null || fh == null || jl == null || specialAttr == null) {
      info(
        'ignore invalid points changes event, ww=$ww, tsb=$tsb, '
        'xc=$xc, tr=$tr, fh=$fh, jl=$jl, specialAttr=$specialAttr',
      );
      return;
    }

    context.read<PointsChangesCubit>().recordsChanges(
      PointsChangesValue(ww: ww, tsb: tsb, xc: xc, tr: tr, fh: fh, jl: jl, specialAttr: specialAttr),
    );
  }

  @override
  void initState() {
    super.initState();
    _pointsChangesSub = pointsChangesStream.stream.listen(_onPointsChanges);
  }

  @override
  void dispose() {
    _pointsChangesSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.globalStatePage;
    return MultiBlocListener(
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
                    AlertDialog(
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
      ],
      child: const SizedBox.shrink(),
    );
  }
}

extension _SignedInteger on int {
  String withSign() =>
      this < 0
          ? '$this'
          : this > 0
          ? '+$this'
          : '0';
}
