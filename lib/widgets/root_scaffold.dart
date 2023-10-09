import 'package:flutter/material.dart';
import 'package:tsdm_client/widgets/app_navitaion_bar.dart';

class RootScaffold extends StatelessWidget {
  const RootScaffold({
    required this.child,
    this.showNavigationBar = false,
    super.key,
  });

  final Widget child;
  final bool showNavigationBar;

  @override
  Widget build(BuildContext context) {
    // TODO: Add animation transition here.
    return Scaffold(
      body: child,
      bottomNavigationBar: showNavigationBar ? const AppNavigationBar() : null,
    );
  }
}
