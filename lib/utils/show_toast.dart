import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

Future<void> showRetryToast(BuildContext context) async {
  toastification.show(
    context: context,
    title: context.t.general.loadFailedAndRetry,
    autoCloseDuration: const Duration(seconds: 3),
  );
  await Future.wait([Future.delayed(const Duration(milliseconds: 400), () {})]);
}

Future<void> showNoMoreToast(BuildContext context) async {
  toastification.show(
    context: context,
    title: context.t.general.noMoreData,
    autoCloseDuration: const Duration(seconds: 3),
  );
}
