import 'package:flutter/material.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// Show a snack bar contains message show no more contents.
Future<void> showNoMoreSnackBar(BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(context.t.general.noMoreData),
    ),
  );
}
