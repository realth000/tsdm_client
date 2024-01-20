import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/checkin_provider.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/checkin_result.dart';
import 'package:tsdm_client/shared/repositories/settings_repository/settings_repository.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/widgets/checkin_button/bloc/checkin_button_bloc.dart';

class CheckInButton extends StatelessWidget {
  const CheckInButton({super.key});

  Future<void> _showCheckinFailedDialog(
      BuildContext context, CheckinResult result) async {
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case CheckinSuccess():
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkin.title,
          message: context.t.profilePage.checkin.success(msg: result.message),
        );
      case CheckinNotAuthorized():
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkin.title,
          message: context.t.profilePage.checkin.failedNotAuthorized,
        );
      case CheckinWebRequestFailed():
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkin.title,
          message: context.t.profilePage.checkin.failedNotAuthorized,
        );
      case CheckinFormHashNotFound():
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkin.title,
          message: context.t.profilePage.checkin.failedFormHashNotFound,
        );
      case CheckinAlreadyChecked():
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkin.title,
          message: context.t.profilePage.checkin.failedAlreadyCheckedIn,
        );
      case CheckinEarlyInTime():
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkin.title,
          message: context.t.profilePage.checkin.failedEarlyInTime,
        );
      case CheckinLateInTime():
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkin.title,
          message: context.t.profilePage.checkin.failedLateInTime,
        );
      case CheckinOtherError():
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkin.title,
          message: context.t.profilePage.checkin
              .failedOtherError(err: result.message),
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
        settingsRepository: RepositoryProvider.of<SettingsRepository>(context),
      ),
      child: BlocListener<CheckinButtonBloc, CheckinButtonState>(
        listener: (context, state) async {
          if (state is CheckinButtonSuccess) {
            return showMessageSingleButtonDialog(
              context: context,
              title: context.t.profilePage.checkin.title,
              message:
                  context.t.profilePage.checkin.success(msg: state.message),
            );
          }
          if (state is CheckinButtonFailed) {
            return _showCheckinFailedDialog(context, state.result);
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
