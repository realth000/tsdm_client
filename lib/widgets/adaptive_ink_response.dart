import 'package:flutter/material.dart';
import 'package:tsdm_client/utils/platform.dart';

/// Tap position representation.
///
/// A general position data structure to carry all kinds of tap details because we only care about the tap position.
class TapPosition {
  /// Constructor.
  const TapPosition({required this.globalPosition, required this.localPosition});

  /// The global position in all kinds of tap details.
  final Offset globalPosition;

  /// The local position in all kinds of tap details.
  final Offset localPosition;

  @override
  String toString() => 'TapPosition { globalPosition: $globalPosition, localPosition: $localPosition }';
}

/// Like [InkResponse], with adaptive gestures.
///
/// See [onAdaptiveContextTap].
///
/// Besides, [hoverColor] and [highlightColor] set to [Colors.transparent] by default to act like [InkWell].
class AdaptiveInkResponse extends StatelessWidget {
  /// Constructor.
  const AdaptiveInkResponse({
    this.child,
    this.onAdaptiveContextTap,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onDoubleTap,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor,
    this.containedInkWell = false,
    this.highlightShape = BoxShape.circle,
    this.radius,
    this.borderRadius,
    this.customBorder,
    this.focusColor,
    this.hoverColor = Colors.transparent,
    this.highlightColor = Colors.transparent,
    this.overlayColor,
    this.splashColor,
    this.splashFactory,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
    this.statesController,
    this.hoverDuration,
    this.behavior,
    super.key,
  });

  /// Adaptively do something.
  ///
  /// * On mobile devices, use [InkResponse.onLongPress].
  /// * On desktop platforms, use [InkResponse.onSecondaryTap].
  final void Function(TapPosition)? onAdaptiveContextTap;

  /// The child widget.
  final Widget? child;

  /// [InkResponse.onTap].
  final GestureTapCallback? onTap;

  /// [InkResponse.onTapDown].
  final GestureTapDownCallback? onTapDown;

  /// [InkResponse.onTapUp].
  final GestureTapUpCallback? onTapUp;

  /// [InkResponse.onTapCancel].
  final GestureTapCallback? onTapCancel;

  /// [InkResponse.onDoubleTap].
  final GestureTapCallback? onDoubleTap;

  /// [InkResponse.onHighlightChanged].
  final ValueChanged<bool>? onHighlightChanged;

  /// [InkResponse.onHover].
  final ValueChanged<bool>? onHover;

  /// [InkResponse.mouseCursor].
  final MouseCursor? mouseCursor;

  /// [InkResponse.containedInkWell].
  final bool containedInkWell;

  /// [InkResponse.highlightShape].
  final BoxShape highlightShape;

  /// [InkResponse.radius].
  final double? radius;

  /// [InkResponse.borderRadius].
  final BorderRadius? borderRadius;

  /// [InkResponse.customBorder].
  final ShapeBorder? customBorder;

  /// [InkResponse.focusColor].
  final Color? focusColor;

  /// [InkResponse.hoverColor].
  final Color? hoverColor;

  /// [InkResponse.highlightColor].
  final Color? highlightColor;

  /// [InkResponse.overlayColor].
  final WidgetStateProperty<Color?>? overlayColor;

  /// [InkResponse.splashColor].
  final Color? splashColor;

  /// [InkResponse.splashFactory].
  final InteractiveInkFeatureFactory? splashFactory;

  /// [InkResponse.enableFeedback].
  final bool enableFeedback;

  /// [InkResponse.excludeFromSemantics].
  final bool excludeFromSemantics;

  /// [InkResponse.onFocusChange].
  final ValueChanged<bool>? onFocusChange;

  /// [InkResponse.autofocus].
  final bool autofocus;

  /// [InkResponse.focusNode].
  final FocusNode? focusNode;

  /// [InkResponse.canRequestFocus].
  final bool canRequestFocus;

  /// [InkResponse.statesController].
  final WidgetStatesController? statesController;

  /// [InkResponse.hoverDuration].
  final Duration? hoverDuration;

  /// [GestureDetector.behavior].
  final HitTestBehavior? behavior;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return GestureDetector(
        behavior: behavior,
        onLongPressStart: (d) =>
            onAdaptiveContextTap?.call(TapPosition(globalPosition: d.globalPosition, localPosition: d.localPosition)),
        child: InkResponse(
          onTap: onTap,
          onTapDown: onTapDown,
          onTapUp: onTapUp,
          onTapCancel: onTapCancel,
          onDoubleTap: onDoubleTap,
          onHighlightChanged: onHighlightChanged,
          onHover: onHover,
          mouseCursor: mouseCursor,
          containedInkWell: containedInkWell,
          highlightShape: highlightShape,
          radius: radius,
          borderRadius: borderRadius,
          customBorder: customBorder,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          overlayColor: overlayColor,
          splashColor: splashColor,
          splashFactory: splashFactory,
          enableFeedback: enableFeedback,
          excludeFromSemantics: excludeFromSemantics,
          focusNode: focusNode,
          canRequestFocus: canRequestFocus,
          onFocusChange: onFocusChange,
          autofocus: autofocus,
          statesController: statesController,
          hoverDuration: hoverDuration,
          child: child,
        ),
      );
    } else {
      return InkResponse(
        onTap: onTap,
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTapCancel: onTapCancel,
        onDoubleTap: onDoubleTap,
        onHighlightChanged: onHighlightChanged,
        onHover: onHover,
        mouseCursor: mouseCursor,
        containedInkWell: containedInkWell,
        highlightShape: highlightShape,
        radius: radius,
        borderRadius: borderRadius,
        customBorder: customBorder,
        focusColor: focusColor,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        overlayColor: overlayColor,
        splashColor: splashColor,
        splashFactory: splashFactory,
        enableFeedback: enableFeedback,
        excludeFromSemantics: excludeFromSemantics,
        focusNode: focusNode,
        canRequestFocus: canRequestFocus,
        onFocusChange: onFocusChange,
        autofocus: autofocus,
        statesController: statesController,
        hoverDuration: hoverDuration,
        onSecondaryTapUp: (d) =>
            onAdaptiveContextTap?.call(TapPosition(globalPosition: d.globalPosition, localPosition: d.localPosition)),
        child: child,
      );
    }
  }
}
