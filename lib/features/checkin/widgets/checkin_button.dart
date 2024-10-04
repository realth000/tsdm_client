import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/checkin/bloc/checkin_bloc.dart';
import 'package:tsdm_client/features/checkin/models/models.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// Widget provides ability to checkin.
class CheckinButton extends StatelessWidget {
  /// Constructor.
  const CheckinButton({super.key});

  Future<void> _showCheckinFailedSnackBar(
    BuildContext context,
    CheckinResult result,
  ) async {
    if (!context.mounted) {
      return;
    }
    final tr = context.t.profilePage.checkin;
    final message = switch (result) {
      CheckinResultSuccess() => tr.success(msg: result.message),
      CheckinResultNotAuthorized() => tr.failedNotAuthorized,
      CheckinResultWebRequestFailed() => tr.failedNotAuthorized,
      CheckinResultFormHashNotFound() => tr.failedFormHashNotFound,
      CheckinResultAlreadyChecked() => tr.failedAlreadyCheckedIn,
      CheckinResultEarlyInTime() => tr.failedEarlyInTime,
      CheckinResultLateInTime() => tr.failedLateInTime,
      CheckinResultOtherError() => tr.failedOtherError(err: result.message),
    };

    return showSnackBar(
      context: context,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.profilePage.checkin;
    return BlocListener<CheckinBloc, CheckinState>(
      listener: (context, state) async {
        if (state is CheckinStateSuccess) {
          return showSnackBar(
            context: context,
            message: tr.success(msg: state.message),
          );
        }
        if (state is CheckinStateFailed) {
          return _showCheckinFailedSnackBar(context, state.result);
        }
      },
      child: BlocBuilder<CheckinBloc, CheckinState>(
        buildWhen: (prev, curr) => prev != curr,
        builder: (context, state) {
          if (state is CheckinStateLoading) {
            return const IconButton(
              icon: sizedCircularProgressIndicator,
              onPressed: null,
            );
          }
          if (state is CheckinStateNeedLogin) {
            return const IconButton(
              icon: Icon(Icons.domain_verification_outlined),
              onPressed: null,
            );
          }
          return IconButton(
            icon: const Icon(Icons.domain_verification_outlined),
            onPressed: () {
              context.read<CheckinBloc>().add(const CheckinRequested());
            },
          );
        },
      ),
    );
  }
}
