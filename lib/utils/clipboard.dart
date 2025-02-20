import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

/// Copy [data] into system clipboard and show a snack bar if [showSnackBar] is
/// true.
Future<void> copyToClipboard(BuildContext context, String data, {bool showSnackBar = true}) async {
  await Clipboard.setData(ClipboardData(text: data));
  if (!context.mounted) {
    return;
  }
  if (showSnackBar) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t.general.copiedToClipboard)));
  }
}
