import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/checkin/bloc/auto_checkin_bloc.dart';
import 'package:tsdm_client/features/root/bloc/root_cubit.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

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
    return BlocProvider(
      create: (_) => RootCubit(),
      child: Builder(
        builder: (context) {
          final rootState = context.watch<RootCubit>().state;
          final autoCheckinState = context.watch<AutoCheckinBloc>().state;

          if (!rootState.showBottomAutoCheckinStatus) {
            if (autoCheckinState is AutoCheckinStatePreparing) {
              return widget.child;
            }
            context.read<RootCubit>().showBottomAutoCheckinStatus();
          }

          final body = switch (autoCheckinState) {
            AutoCheckinStateInitial() ||
            AutoCheckinStatePreparing() =>
              sizedBoxEmpty,
            AutoCheckinStateLoading() => Row(
                children: [
                  sizedCircularProgressIndicator,
                  sizedBoxW16H16,
                  Text(tr.autoCheckinRunning),
                ],
              ),
            AutoCheckinStateFinished() => Row(
                children: [
                  const Icon(Icons.check_outlined),
                  sizedBoxW16H16,
                  Text(tr.autoCheckinFinished),
                ],
              ),
          };
          return Scaffold(
            body: widget.child,
            bottomNavigationBar: body,
          );
        },
      ),
    );
  }
}
