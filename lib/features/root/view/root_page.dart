import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/checkin/bloc/auto_checkin_bloc.dart';
import 'package:tsdm_client/features/notification/bloc/auto_notification_cubit.dart';
import 'package:tsdm_client/features/notification/bloc/notification_bloc.dart';
import 'package:tsdm_client/features/root/bloc/root_location_cubit.dart';
import 'package:tsdm_client/features/root/models/models.dart';
import 'package:tsdm_client/features/root/stream/root_location_stream.dart';
import 'package:tsdm_client/features/update/cubit/update_cubit.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/git_info.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// A top-level wrapper page for showing messages or provide functionalities to
/// all pages across the app.
class RootPage extends StatefulWidget {
  /// Constructor.
  const RootPage(this.path, this.child, {super.key});

  /// Current screen path.
  final String path;

  /// Content widget.
  final Widget child;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with LoggerMixin {
  @override
  void initState() {
    super.initState();
    rootLocationStream.add(RootLocationEventEnter(widget.path));
  }

  @override
  void dispose() {
    rootLocationStream.add(RootLocationEventLeave(widget.path));
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
              showSnackBar(context: context, message: tr.failed);
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
                  return AlertDialog(
                    title: Text(tr.availableDialog.changelog),
                    content: SizedBox(
                      width: size.width * 0.7,
                      height: size.height * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr.availableDialog.version(version: info.version),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                          ),
                          sizedBoxW12H12,
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
                  );
                },
              );
              if (true == gotoUpdatePage && context.mounted && !inUpdatePage) {
                await context.pushNamed(ScreenPaths.update);
              }
            }
          },
        ),
      ],
      child: widget.child,
    );
  }
}
