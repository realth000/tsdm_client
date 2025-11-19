import 'package:flutter/material.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

/// The circular indicator used app wide.
class CircularIndicator extends StatelessWidget {
  /// Constructor.
  const CircularIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingIndicatorM3E();
  }
}

/// The circular indicator auto center-aligned used app wide.
class CenteredCircularIndicator extends StatelessWidget {
  /// Constructor.
  const CenteredCircularIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularIndicator());
  }
}
