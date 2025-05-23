import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

/// Provide size transition when [child] widget becomes to visible or invisible.
class AnimatedVisibility extends StatelessWidget {
  /// Constructor.
  const AnimatedVisibility({required this.visible, required this.child, this.duration, super.key});

  /// Control the visibility of [child].
  final bool visible;

  /// Child widget that controlled to be visible and invisible.
  final Widget child;

  /// Duration to run the animation.
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) =>
          SizeTransition(sizeFactor: animation, axisAlignment: 1, child: child),
      duration: duration ?? duration100,
      child: visible ? child : null,
    );
  }
}
