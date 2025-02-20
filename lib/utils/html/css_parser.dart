import 'dart:ui';

import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/html/web_colors.dart';

final _colorRe = RegExp(r'^(#)?[0-9a-fA-F]{1,6}$');

/// Parse a [String] of css to [CssTypes].
///
/// Return null if is invalid css.
CssTypes? parseCssString(String css) {
  Color? backgroundColor;
  Color? color;
  FontWeight? fontWeight;
  final cssList = css.split(';');
  for (final c in cssList) {
    final p = _parseCssPart(c);
    if (p == null) {
      continue;
    }
    final name = p.$1;
    final value = p.$2.trim();
    switch (name) {
      case 'font-weight':
        fontWeight = _parseFontWeight(value);
      case 'color':
        color = value.toColor();
      case 'background-color':
        backgroundColor = value.toColor();
      default:
        continue;
    }
  }

  final ret = CssTypes(color: color, fontWeight: fontWeight, backgroundColor: backgroundColor);
  return ret;
}

FontWeight? _parseFontWeight(String data) {
  return switch (data) {
    '100' => FontWeight.w100,
    '200' => FontWeight.w200,
    '300' => FontWeight.w300,
    '400' => FontWeight.w400,
    '500' => FontWeight.w500,
    '600' => FontWeight.w600,
    '700' => FontWeight.w700,
    '800' => FontWeight.w800,
    '900' => FontWeight.w900,
    'bold' => FontWeight.bold,
    String() => null,
  };
}

(String key, String value)? _parseCssPart(String cssPart) {
  final separateIndex = cssPart.indexOf(':');
  if (separateIndex < 0 || separateIndex == cssPart.length - 1) {
    return null;
  }

  return (cssPart.substring(0, separateIndex), cssPart.substring(separateIndex + 1));
}

/// Extension to convert nullable string to [Color].
extension StringToColorExt on String? {
  /// Parse nullable color string to [Color].
  ///
  /// * If `this` is null, return null.
  /// * Parse `this` in style `#COLOR_VALUE` or `COLOR_NAME` where COLOR_NAME is
  ///   hit in [WebColors].
  Color? toColor() {
    int? colorValue;
    // Parse as color value.
    if (this != null && _colorRe.hasMatch(this!)) {
      if (this!.startsWith('#')) {
        if (this!.length == 4) {
          // #abc format short hand for #aabbcc.
          colorValue = int.tryParse(
            '${this![1]}${this![1]}${this![2]}'
            '${this![2]}${this![3]}${this![3]}',
            radix: 16,
          );
        } else {
          // Normal #aabbcc format.
          colorValue = int.tryParse(this!.substring(1), radix: 16);
        }
      } else {
        colorValue = int.tryParse(this!, radix: 16);
      }
    }
    if (colorValue != null) {
      colorValue += 0xFF000000;
      return Color(colorValue);
    } else {
      // If color not in format #aabcc, try parse as color name.
      final webColor = WebColors.fromString(this);
      if (webColor.isValid) {
        return webColor.color;
      }
    }
    return null;
  }
}
