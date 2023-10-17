import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/check_in_provider.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';

class CheckInButton extends ConsumerWidget {
  const CheckInButton({super.key});

  Future<void> _checkIn(BuildContext context, WidgetRef ref) async {
    final (result, message) =
        await ref.read(checkInProvider.notifier).checkIn();
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case CheckInResult.success:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.success(msg: '$message'),
        );
      case CheckInResult.notAuthorized:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.failedNotAuthorized,
        );
      case CheckInResult.webRequestFailed:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.failedRequest(err: '$message'),
        );
      case CheckInResult.formHashNotFound:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.failedFormHashNotFound,
        );
      case CheckInResult.alreadyCheckedIn:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.failedAlreadyCheckedIn,
        );
      case CheckInResult.earlyInTime:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.failedEarlyInTime,
        );
      case CheckInResult.lateInTime:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.failedLateInTime,
        );
      case CheckInResult.otherError:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message:
              context.t.profilePage.checkIn.failedOtherError(err: '$message'),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DebounceIconButton(
      icon: const Icon(Icons.domain_verification),
      shouldDebounce: ref.watch(checkInProvider),
      onPressed: () async => _checkIn(context, ref),
    );
  }
}
