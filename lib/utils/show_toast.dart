import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

Future<void> showRetryToast(BuildContext context) async {
  toastification.show(
    context: context,
    title: context.t.general.loadFailedAndRetry,
    autoCloseDuration: const Duration(seconds: 1),
  );
  await Future.wait(
      [Future.delayed(const Duration(milliseconds: 400), () {})]);
}
