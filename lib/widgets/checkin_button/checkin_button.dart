import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/checkin_provider.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/checkin_result.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/checkin_button/bloc/checkin_button_bloc.dart';

/// Widget provides ability to checkin.
class CheckInButton extends StatelessWidget {
  /// Constructor.
  const CheckInButton({super.key});

  Future<void> _showCheckinFailedSnackBar(
    BuildContext context,
    CheckinResult result,
  ) async {
    if (!context.mounted) {
      return;
    }
    final tr = context.t.profilePage.checkin;
    switch (result) {
      case CheckinSuccess():
        return showSnackBar(
          context: context,
          message: tr.success(msg: result.message),
        );
      case CheckinNotAuthorized():
        return showSnackBar(
          context: context,
          message: tr.failedNotAuthorized,
        );
      case CheckinWebRequestFailed():
        return showSnackBar(
          context: context,
          message: tr.failedNotAuthorized,
        );
      case CheckinFormHashNotFound():
        return showSnackBar(
          context: context,
          message: tr.failedFormHashNotFound,
        );
      case CheckinAlreadyChecked():
        return showSnackBar(
          context: context,
          message: tr.failedAlreadyCheckedIn,
        );
      case CheckinEarlyInTime():
        return showSnackBar(
          context: context,
          message: tr.failedEarlyInTime,
        );
      case CheckinLateInTime():
        return showSnackBar(
          context: context,
          message: tr.failedLateInTime,
        );
      case CheckinOtherError():
        return showSnackBar(
          context: context,
          message: tr.failedOtherError(err: result.message),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CheckinButtonBloc(
        checkinProvider: getIt.get<CheckinProvider>(),
        authenticationRepository:
            RepositoryProvider.of<AuthenticationRepository>(context),
        settingsRepository: getIt.get<SettingsRepository>(),
      ),
      child: BlocListener<CheckinButtonBloc, CheckinButtonState>(
        listener: (context, state) async {
          if (state is CheckinButtonSuccess) {
            return showSnackBar(
              context: context,
              message:
                  context.t.profilePage.checkin.success(msg: state.message),
            );
          }
          if (state is CheckinButtonFailed) {
            return _showCheckinFailedSnackBar(context, state.result);
          }
        },
        child: BlocBuilder<CheckinButtonBloc, CheckinButtonState>(
          buildWhen: (prev, curr) => prev != curr,
          builder: (context, state) {
            if (state is CheckinButtonLoading) {
              return const IconButton(
                icon: sizedCircularProgressIndicator,
                onPressed: null,
              );
            }
            if (state is CheckinButtonNeedLogin) {
              return const IconButton(
                icon: Icon(Icons.domain_verification_outlined),
                onPressed: null,
              );
            }
            return IconButton(
              icon: const Icon(Icons.domain_verification_outlined),
              onPressed: () {
                context
                    .read<CheckinButtonBloc>()
                    .add(const CheckinButtonRequested());
              },
            );
          },
        ),
      ),
    );
  }
}
