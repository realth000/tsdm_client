import 'dart:math' as math;

import 'package:flutter/material.dart';

const _visibleLuminance = 60;

/// Make the color adaptive with dark mode.
extension AdaptiveColorExt on Color {
  // From flex_color_scheme.
  Color _lighten([int amount = 10]) {
    if (amount <= 0) return this;
    if (amount > 100) return Colors.white;
    // HSLColor returns saturation 1 for black, we want 0 instead to be able
    // lighten black color up along the grey scale from black.
    final hsl = this == const Color(0xFF000000)
        ? HSLColor.fromColor(this).withSaturation(0)
        : HSLColor.fromColor(this);
    return hsl
        .withLightness(math.min(1, math.max(0, hsl.lightness + amount / 100)))
        .toColor();
  }

  // From flex_color_scheme.
  Color _blendAlpha(Color input, [int alpha = 0x0A]) {
    // Skip blending for impossible value and return the instance color value.
    if (alpha <= 0) return this;
    // Blend amounts >= 255 results in the input Color.
    if (alpha >= 255) return input;
    return Color.alphaBlend(input.withAlpha(alpha), this);
  }

  // refer: https://stackoverflow.com/a/596243
  int _calcLuminance() {
    return (0.2126 * red + 0.7152 * green + 0.0722 * blue).truncate();
  }

  Color _inverted() {
    final r = 255 - red;
    final g = 255 - green;
    final b = 255 - blue;

    return Color.fromARGB((opacity * 255).round(), r, g, b);
  }

  /// Transform into a more contrastive color on dark background.
  Color adaptiveDark() {
    final lum = _calcLuminance();
    if (lum >= _visibleLuminance) {
      return this;
    }

    return _blendAlpha(_inverted(), (_visibleLuminance - lum) * 4)._lighten(1);
  }
}
