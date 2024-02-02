import 'package:flutter/material.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

Widget buildRetryButton(BuildContext context, VoidCallback onPressed) {
  return Center(
    child: ElevatedButton(
      onPressed: onPressed,
      child: Text(context.t.general.retry),
    ),
  );
}
