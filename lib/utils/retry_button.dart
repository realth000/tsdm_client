import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

/// Build a retry button with [context] and callback [onPressed].
Widget buildRetryButton(BuildContext context, VoidCallback onPressed) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Image.asset(assetErrorImagePath),
        ),
        sizedBoxW24H24,
        FilledButton(
          onPressed: onPressed,
          child: Text(context.t.general.retry),
        ),
      ],
    ),
  );
}
