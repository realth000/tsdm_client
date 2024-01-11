import 'package:flutter/material.dart';

Widget buildRetrySnackbarButton(BuildContext context, VoidCallback onPressed) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Load failed'),
    ),
  );
  return Center(
    child: ElevatedButton(
      child: Text('Try again'),
      onPressed: onPressed,
    ),
  );
}
