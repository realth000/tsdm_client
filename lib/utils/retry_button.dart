import 'package:flutter/material.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/card/error_card.dart';

/// Build a retry button with [context] and callback [onPressed].
Widget buildRetryButton(BuildContext context, VoidCallback onPressed, {String? message}) {
  return ErrorCard(
    message: message,
    child: FilledButton(onPressed: onPressed, child: Text(context.t.general.retry)),
  );
}
