import 'package:flutter/material.dart';

class RootScaffold extends StatelessWidget {
  const RootScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
    );
  }
}
