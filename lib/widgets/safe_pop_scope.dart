import 'package:flutter/material.dart';
import 'package:tsdm_client/features/root/models/models.dart';
import 'package:tsdm_client/features/root/stream/root_location_stream.dart';

/// Wrapper widget handle page popping events.
class SafePopScope extends StatelessWidget {
  /// Constructor.
  const SafePopScope({required this.path, required this.child, super.key});

  /// Route path of [child] page.
  final String path;

  /// Wrapped child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, b) {
        if (!didPop) {
          // When popping event passed location check, `didPop` is true, do not recursively handle it.
          rootLocationStream.add(const RootLocationEventLeavingLast());
        }
      },
      child: child,
    );
  }
}
