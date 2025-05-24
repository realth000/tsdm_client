import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';

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
      return RootPage(
        DialogPaths.messageSingleButton,
        AlertDialog(
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
        ),
      );
    },
  );
}

/// Show a dialog with given [title] and [message] to ask user a question.
///
/// Return true if user pressed ok.
/// Return false if user pressed cancel.
/// Return null if user pressed outside the dialog to close it.
///
/// For rich text, use [richMessage] parameter.
Future<bool?> showQuestionDialog({
  required BuildContext context,
  required String title,
  String? message,
  TextSpan? richMessage,
  bool dangerous = false,
}) async {
  assert(message != null || richMessage != null, 'MUST provide message or richMessage');

  return showDialog<bool?>(
    context: context,
    builder: (context) {
      return RootPage(
        DialogPaths.question,
        AlertDialog(
          scrollable: true,
          title: Text(title),
          content: message != null ? SelectableText(message) : Text.rich(richMessage!),
          actions: [
            TextButton(
              child: Text(context.t.general.cancel),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: Text(
                context.t.general.ok,
                style: dangerous ? TextStyle(color: Theme
                    .of(context)
                    .colorScheme
                    .error) : null,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      );
    },
  );
}
