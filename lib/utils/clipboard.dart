import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/show_toast.dart' as toast;

/// Copy [data] into system clipboard and show a snack bar if [showSnackBar] is
/// true.
Future<void> copyToClipboard(BuildContext context, String data, {bool showSnackBar = true}) async {
  await Clipboard.setData(ClipboardData(text: data));
  if (!context.mounted) {
    return;
  }
  if (showSnackBar) {
    toast.showSnackBar(context: context, message: context.t.general.copiedToClipboard);
  }
}

/// Get the plain text content in system clipboard.
Future<String?> getPlainTextFromClipboard() async {
  final data = await Clipboard.getData('text/plain');
  return data?.text;
}
