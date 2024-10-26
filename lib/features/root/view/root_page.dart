import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/features/checkin/bloc/auto_checkin_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// A top-level wrapper page for showing messages or provide functionalities to
/// all pages across the app.
class RootPage extends StatefulWidget {
  /// Constructor.
  const RootPage(this.child, {super.key});

  /// Content widget.
  final Widget child;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  Widget build(BuildContext context) {
    final tr = context.t.globalStatePage;
    return BlocListener<AutoCheckinBloc, AutoCheckinState>(
      listenWhen: (prev, curr) =>
          prev is! AutoCheckinStateFinished && curr is AutoCheckinStateFinished,
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
      child: widget.child,
    );
  }
}
