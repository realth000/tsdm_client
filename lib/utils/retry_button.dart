import 'package:flutter/material.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// Build a retry button with [context] and callback [onPressed].
Widget buildRetryButton(BuildContext context, VoidCallback onPressed) {
  return Center(
    child: FilledButton(
      onPressed: onPressed,
      child: Text(context.t.general.retry),
    ),
  );
}
