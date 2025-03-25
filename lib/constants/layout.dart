import 'package:flutter/material.dart';

/// Duration 100 milliseconds.
const duration100 = Duration(milliseconds: 100);

/// Duration 200 milliseconds.
const duration200 = Duration(milliseconds: 200);

/// Duration 500 milliseconds.
const duration500 = Duration(milliseconds: 500);

/// Min button width of button in a card in post.
///
/// Including LockedCard.
const sizeButtonInCardMinWidth = 200.0;

/// Zero size [SizedBox] represents no widget.
const sizedBoxEmpty = SizedBox.shrink();

/// A [SizedBox] with 2 width and 2 height.
const sizedBoxW2H2 = SizedBox(width: 2, height: 2);

/// A [SizedBox] with 4 width and 4 height.
const sizedBoxW4H4 = SizedBox(width: 4, height: 4);

/// A [SizedBox] with 8 width and 8 height.
const sizedBoxW8H8 = SizedBox(width: 8, height: 8);

/// A [SizedBox] with 12 width and 12 height.
const sizedBoxW12H12 = SizedBox(width: 12, height: 12);

/// A [SizedBox] with 16 width and 16 height.
const sizedBoxW16H16 = SizedBox(width: 16, height: 16);

/// A [SizedBox] with 24 width and 24 height.
const sizedBoxW24H24 = SizedBox(width: 24, height: 25);

/// A [SizedBox] with 32 width and 32 height.
const sizedBoxW32H32 = SizedBox(width: 32, height: 32);

/// A [SizedBox] with 12 width and 48 height.
///
/// Size following [material design 3 spec](https://m3.material.io/components/menus/specs#6928c7b9-2c6e-4ff6-98a6-55883fb299bd).
const sizedBoxPopupMenuItemIconSpacing = SizedBox(width: 12, height: 48);

/// An [EdgeInsets] 4 at top and 4 at bottom.
const edgeInsetsT4B4 = EdgeInsets.only(top: 4, bottom: 4);

/// An [EdgeInsets] with 4 at top.
const edgeInsetsT4 = EdgeInsets.only(top: 4);

/// An [EdgeInsets] with 8 at top.
const edgeInsetsT8 = EdgeInsets.only(top: 8);

/// An [EdgeInsets] 4 at right.
const edgeInsetsR4 = EdgeInsets.only(right: 4);

/// An [EdgeInsets] 4 at bottom.
const edgeInsetsB4 = EdgeInsets.only(bottom: 4);

/// An [EdgeInsets] with 8 at right.
const edgeInsetsR8 = EdgeInsets.only(right: 8);

/// An [EdgeInsets] with 4 at left and 4 at right.
const edgeInsetsL4R4 = EdgeInsets.only(left: 4, right: 4);

/// An [EdgeInsets] with 8 at left and 8 at right.
const edgeInsetsL8R8 = EdgeInsets.only(left: 8, right: 8);

/// An [EdgeInsets] with 16 at left and 16 at right.
const edgeInsetsL16R16 = EdgeInsets.only(left: 16, right: 16);

/// An [EdgeInsets] with 16 at left, top, right and bottom.
const edgeInsetsL16T16R16B16 = EdgeInsets.all(16);

/// An [EdgeInsets] with 16 at left and 16 at right, 12 at top and 12 at bottom.
const edgeInsetsL16T12R16B12 = EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 12);

/// An [EdgeInsets] with 12 at left, top and right.
const edgeInsetsL12T12R12 = EdgeInsets.only(left: 12, top: 12, right: 12);

/// An [EdgeInsets] with 4 at top, 12 at left, right and bottom.
const edgeInsetsL12T4R12B12 = EdgeInsets.only(left: 12, top: 4, right: 12, bottom: 12);

/// An [EdgeInsets] with 12 at left, top, right and bottom.
const edgeInsetsL12T12R12B12 = EdgeInsets.all(12);

/// An [EdgeInsets] with 10 at top, right and bottom.
const edgeInsetsL12R12B12 = EdgeInsets.only(left: 12, right: 12, bottom: 12);

/// An [EdgeInsets] with 12 at top and right, 24 at bottom.
const edgeInsetsL12R12B24 = EdgeInsets.only(left: 12, right: 12, bottom: 24);

/// An [EdgeInsets] with 16 at left and right, 12 at bottom.
const edgeInsetsL16R16B12 = EdgeInsets.only(left: 16, right: 16, bottom: 12);

/// An [EdgeInsets] with 24 at left and right.
const edgeInsetsL24R24 = EdgeInsets.only(left: 24, right: 24);

/// An [EdgeInsets] with 24 at left and right, 12 at bottom.
const edgeInsetsL24R24B12 = EdgeInsets.only(left: 24, right: 24, bottom: 12);

/// An [EdgeInsets] with 24 at left and right, 16 at top and bottom.
const edgeInsetsL24T12R24B12 = EdgeInsets.symmetric(horizontal: 24, vertical: 12);

/// An [EdgeInsets] with 12 at left, 4 at top and 4 at bottom.
const edgeInsetsL12T4R4B4 = EdgeInsets.only(left: 12, top: 4, right: 4, bottom: 4);

/// An [EdgeInsets] with 12 at left, 4 at top and 12 at right.
const edgeInsetsL12T4R12 = EdgeInsets.only(left: 12, top: 4, right: 12);

/// An [EdgeInsets] with 12 at left, 8 at top and 12 at right.
const edgeInsetsL12T8R12 = EdgeInsets.only(left: 12, top: 8, right: 12);

/// An [EdgeInsets] with 12 at left, 4 at top, 12 at right and 4 at bottom.
const edgeInsetsL12T4R12B4 = EdgeInsets.only(left: 12, top: 4, right: 12, bottom: 4);

/// An [EdgeInsets] with 12 at left and 12 at right.
const edgeInsetsL12R12 = EdgeInsets.only(left: 12, right: 12);

/// An [EdgeInsets] with 60 at left and 12 at bottom.
const edgeInsetsL60B12 = EdgeInsets.only(left: 60, bottom: 12);

/// A minimum sized [CircularProgressIndicator] that should use in buttons.
const sizedCircularProgressIndicator = SizedBox(
  width: 24,
  height: 24,
  child: CircularProgressIndicator(strokeWidth: 2.5),
);

/// Widget with 24 height and infinite width to use in shimmers.
const sizedH24Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(width: double.infinity, height: 24, child: ColoredBox(color: Colors.white)),
);

/// Widget with 40 width and height to use in shimmers.
const sizedW40H40Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(width: 40, height: 40, child: ColoredBox(color: Colors.white)),
);

/// Widget with 40 width and height to use in shimmers.
const sizedW80H40Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(width: 80, height: 40, child: ColoredBox(color: Colors.white)),
);

/// Widget with 80 width and height to use in shimmers.
const sizedW120H40Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(width: 120, height: 40, child: ColoredBox(color: Colors.white)),
);

/// Widget with 40 height and infinite width to use in shimmers.
const sizedH40Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(width: double.infinity, height: 40, child: ColoredBox(color: Colors.white)),
);

/// Widget with 60 height infinite width to use in shimmers.
///
const sizedH60Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(width: double.infinity, height: 60, child: ColoredBox(color: Colors.white)),
);

/// Widget with 100 height infinite width to use in shimmers.
///
const sizedH100Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(width: double.infinity, height: 100, child: ColoredBox(color: Colors.white)),
);

/// Define window size boundaries.
///
/// All values are following [Material Design 3](https://m3.material.io/foundations/layout/applying-layout/window-size-classes).
enum WindowSize {
  /// Compact size.
  ///
  /// [0, 599]
  compact('COMPACT', 0, 599),

  /// Medium size.
  ///
  /// [600, 839]
  medium('MEDIUM', 600, 839),

  /// Expanded size.
  ///
  /// [840, 1199]
  expanded('EXPANDED', 840, 1199),

  /// Large size.
  ///
  /// [1200, 1599]
  large('LARGE', 1200, 1599),

  /// Extra large size.
  ///
  /// [1600, +infinity)
  extraLarge('EXTRA_LARGE', 1600, double.infinity);

  const WindowSize(this.name, this.start, this.end) : assert(start < end, 'start MUST less than end');

  /// Name of window size.
  final String name;

  /// Start of width range of window size.
  ///
  /// DP on Android and default LP in flutter, both are the same.
  final double start;

  /// End of width range of window size.
  ///
  /// DP on Android and default LP in flutter, both are the same.
  final double end;
}

// All values of variables in this section are defined in Material 3 spec:
// https://m3.material.io/components/

/// Spec defined [TextField] height.
const specTextFieldHeight = 56.0;
