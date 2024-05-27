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

/// A [SizedBox] with 5 width and 5 height.
const sizedBoxW5H5 = SizedBox(width: 5, height: 5);

/// A [SizedBox] with 10 width and 10 height.
const sizedBoxW10H10 = SizedBox(width: 10, height: 10);

/// A [SizedBox] with 15 width and 15 height.
const sizedBoxW15H15 = SizedBox(width: 15, height: 15);

/// A [SizedBox] with 20 width and 20 height.
const sizedBoxW20H20 = SizedBox(width: 20, height: 20);

/// An [EdgeInsets] with 10 at top.
const edgeInsetsT10 = EdgeInsets.only(top: 10);

/// An [EdgeInsets] with 10 at left and 10 at right.
const edgeInsetsL10R10 = EdgeInsets.only(left: 10, right: 10);

/// An [EdgeInsets] with 15 at left and 15 at right.
const edgeInsetsL15R15 = EdgeInsets.only(left: 15, right: 15);

/// An [EdgeInsets] with 15 at left, top, right and bottom.
const edgeInsetsL15T15R15B15 = EdgeInsets.all(15);

/// An [EdgeInsets] with 18 at left and 18 at right.
const edgeInsetsL18R18 = EdgeInsets.symmetric(horizontal: 18);

/// An [EdgeInsets] with 10 at left, top and right.
const edgeInsetsL10T10R10 = EdgeInsets.only(left: 10, top: 10, right: 10);

/// An [EdgeInsets] with 10 at top, right and bottom.
const edgeInsetsL10R10B10 = EdgeInsets.only(left: 10, right: 10, bottom: 10);

/// An [EdgeInsets] with 10 at top and right, 20 at bottom.
const edgeInsetsL10R10B20 = EdgeInsets.only(left: 10, right: 10, bottom: 20);

/// An [EdgeInsets] with 15 at left and right, 10 at bottom.
const edgeInsetsL15R15B10 = EdgeInsets.only(left: 15, right: 15, bottom: 10);

/// An [EdgeInsets] with 20 at left and right.
const edgeInsetsL20R20 = EdgeInsets.only(left: 20, right: 20);

/// An [EdgeInsets] with 20 at left and right, 10 at bottom.
const edgeInsetsL20R20B10 = EdgeInsets.only(left: 20, right: 20, bottom: 10);

/// An [EdgeInsets] with 10 at left, 5 at top and 5 at bottom.
const edgeInsetsL10T5R5B5 =
    EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 5);

/// An [EdgeInsets] with 10 at left, 5 at top and 10 at right.
const edgeInsetsL10T5R10 = EdgeInsets.only(left: 10, top: 5, right: 10);

/// An [EdgeInsets] with 10 at left, 5 at top, 10 at right and 20 at bottom.
const edgeInsetsL10T5R10B20 =
    EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 20);

/// An [EdgeInsets] with 60 at left and 10 at bottom.
const edgeInsetsL60B10 = EdgeInsets.only(left: 60, bottom: 10);

/// A minimum sized [CircularProgressIndicator] that should use in buttons.
const sizedCircularProgressIndicator = SizedBox(
  width: 16,
  height: 16,
  child: CircularProgressIndicator(strokeWidth: 3),
);

/// Widget with 20 height and infinite width to use in shimmers.
const sizedH20Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(
    width: double.infinity,
    height: 20,
    child: ColoredBox(
      color: Colors.white,
    ),
  ),
);

/// Widget with 40 width and height to use in shimmers.
const sizedW40H40Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(
    width: 40,
    height: 40,
    child: ColoredBox(
      color: Colors.white,
    ),
  ),
);

/// Widget with 40 width and height to use in shimmers.
const sizedW80H40Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(
    width: 80,
    height: 40,
    child: ColoredBox(
      color: Colors.white,
    ),
  ),
);

/// Widget with 80 width and height to use in shimmers.
const sizedW120H40Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(
    width: 120,
    height: 40,
    child: ColoredBox(
      color: Colors.white,
    ),
  ),
);

/// Widget with 40 height and infinite width to use in shimmers.
const sizedH40Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(
    width: double.infinity,
    height: 40,
    child: ColoredBox(
      color: Colors.white,
    ),
  ),
);

/// Widget with 60 height infinite width to use in shimmers.
///
const sizedH60Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(
    width: double.infinity,
    height: 60,
    child: ColoredBox(
      color: Colors.white,
    ),
  ),
);

/// Widget with 100 height infinite width to use in shimmers.
///
const sizedH100Shimmer = ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  child: SizedBox(
    width: double.infinity,
    height: 100,
    child: ColoredBox(
      color: Colors.white,
    ),
  ),
);
