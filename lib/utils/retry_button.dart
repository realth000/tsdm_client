import 'package:flutter/material.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

Widget buildRetryButton(BuildContext context, VoidCallback onPressed) {
  return Center(
    child: ElevatedButton(
      child: Text(context.t.general.retry),
      onPressed: onPressed,
    ),
  );
}
