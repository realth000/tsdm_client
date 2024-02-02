import 'package:flutter/material.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

Future<void> showNoMoreSnackBar(BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(context.t.general.noMoreData),
  ),);
}
