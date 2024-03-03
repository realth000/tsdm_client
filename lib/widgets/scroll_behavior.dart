import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Can drag by mouse, and touch.
class AllDraggableScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
