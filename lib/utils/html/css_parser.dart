import 'dart:ui';

import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/html/web_colors.dart';

/// Parse a [String] of css to [CssTypes].
///
/// Return null if is invalid css.
CssTypes? parseCssString(String css) {
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
        color = _parseColor(value);
      default:
        continue;
    }
  }

  final ret = CssTypes(color: color, fontWeight: fontWeight);
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

  return (
    cssPart.substring(0, separateIndex),
    cssPart.substring(separateIndex + 1)
  );
}

/// FIXME: Separate web color parsing.
Color? _parseColor(String data) {
  final webColor = WebColors.fromString(data);
  if (webColor.isValid) {
    return webColor.color;
  }

  if (data.startsWith('#')) {
    final v = int.tryParse(data.substring(1).padLeft(8, 'ff'), radix: 16);
    if (v == null) {
      return null;
    }
    return Color(v);
  }
  return null;
}
