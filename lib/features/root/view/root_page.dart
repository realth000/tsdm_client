import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/features/checkin/bloc/auto_checkin_bloc.dart';
import 'package:tsdm_client/features/notification/bloc/auto_notification_cubit.dart';
import 'package:tsdm_client/features/root/models/models.dart';
import 'package:tsdm_client/features/root/stream/root_location_stream.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
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
          listenWhen: (prev, curr) =>
              prev is! AutoCheckinStateFinished &&
              curr is AutoCheckinStateFinished,
          listener: (context, state) {
            if (state is AutoCheckinStateFinished) {
              showSnackBar(
                context: context,
                message: tr.autoCheckinFinished,
                action: SnackBarAction(
                  label: tr.viewDetail,
                  onPressed: () async =>
                      context.pushNamed(ScreenPaths.autoCheckinDetail),
                ),
              );
            }
          },
        ),
        BlocListener<AutoNotificationCubit, AutoNoticeState>(
          listenWhen: (prev, curr) =>
              curr is AutoNoticeStatePending && prev != curr,
          listener: (context, state) {
            // Add this check to make dart-analyzer happy.
            if (state is! AutoNoticeStatePending) {
              return;
            }
            debug('auto fetch got notice');
          },
        ),
      ],
      child: widget.child,
    );
  }
}
