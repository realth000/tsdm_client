import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

/// Show a bottom sheet with given [title] and build children
/// with [childrenBuilder].
Future<void> showCustomBottomSheet({
  required BuildContext context,
  required String title,
  required List<Widget> Function(BuildContext context) childrenBuilder,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return Scaffold(
        body: Padding(
          padding: edgeInsetsL15T15R15B15,
          child: Column(
            children: [
              SizedBox(height: 50, child: Center(child: Text(title))),
              sizedBoxW10H10,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: childrenBuilder(context)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
