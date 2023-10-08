import 'package:flutter/material.dart';

class RootScaffold extends StatelessWidget {
  const RootScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // TODO: Add animation transition here.
    return Scaffold(
      body: child,
    );
  }
}
