import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// Show a dialog with given [title] and [message], with a ok button to navigate
/// back.
Future<void> showMessageSingleButtonDialog({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        scrollable: true,
        title: Text(title),
        content: SelectableText(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(context.t.general.ok),
          ),
        ],
      );
    },
  );
}

/// Show a dialog with given [title] and [message] to ask user a question.
///
/// Return true if user pressed ok.
/// Return false if user pressed cancel.
/// Return null if user pressed outside the dialog to close it.
Future<bool?> showQuestionDialog({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  return showDialog<bool?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        scrollable: true,
        title: Text(title),
        content: SelectableText(message),
        actions: [
          TextButton(
            child: Text(context.t.general.cancel),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          TextButton(
            child: Text(context.t.general.ok),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      );
    },
  );
}

/// Show a dialog while doing [work] and close after work finished.
Future<void> showModalWorkDialog({
  required BuildContext context,
  required String message,
  required FutureOr<void> Function() work,
}) async {
  BuildContext? dialogContext;
  // DO NOT AWAIT
  // ignore:unawaited_futures
  showDialog<void>(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      dialogContext = context;
      return AlertDialog(
        scrollable: true,
        title: Text(context.t.general.pleaseWait),
        content: SelectableText(message),
      );
    },
  ).then((_) {
    dialogContext = null;
  });

  final atLeast = Future<void>.delayed(const Duration(seconds: 1));

  if (work is Future<void> Function()) {
    await Future.wait([work(), atLeast]);
  } else {
    await Future.wait([Future.value(work()), atLeast]);
  }

  if (!context.mounted) {
    return;
  }
  if (dialogContext == null) {
    return;
  }
  Navigator.of(dialogContext!).pop();
}
