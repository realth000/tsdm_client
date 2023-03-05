import 'package:flutter/material.dart';

/// Page to show error.
class ErrorRoutePage extends StatelessWidget {
  /// Constructor.
  const ErrorRoutePage(
    this.msg, {
    super.key,
  });

  /// Message to show including failed reason.
  final String msg;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Text(msg),
        ),
      );
}
