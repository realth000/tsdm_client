import 'dart:math' as math;

import 'package:flutter/material.dart';

// Convert calculation comes from darkreader.
// Not the same but similar result.

typedef _Matrix5 = List<List<num>>;

const _identifiedMatrix = [
  [1, 0, 0, 0, 0],
  [0, 1, 0, 0, 0],
  [0, 0, 1, 0, 0],
  [0, 0, 0, 1, 0],
  [0, 0, 0, 0, 1],
];

const _invertNHueMatrix = [
  [0.333, -0.667, -0.667, 0, 1],
  [-0.667, 0.333, -0.667, 0, 1],
  [-0.667, -0.667, 0.333, 0, 1],
  [0, 0, 0, 1, 0],
  [0, 0, 0, 0, 1],
];

_Matrix5 _multiplyMatrix(_Matrix5 m1, _Matrix5 m2) {
  _Matrix5 result;
  result = List.generate(
    m1.length,
    (_) => List.generate(
      m2.length,
      (_) => 0,
    ),
  );
  for (var i = 0, len = m1.length; i < len; i++) {
    result[i] = List.generate(len, (_) => 0);
    for (var j = 0, len2 = m2[0].length; j < len2; j++) {
      num sum = 0;
      // 3. m1[0].length是列数
      for (var k = 0, len3 = m1[0].length; k < len3; k++) {
        sum += m1[i][k] * m2[k][j];
      }
      result[i][j] = sum;
    }
  }
  return result;
}

List<num> _applyColorMatrix(Color color, _Matrix5 m) {
  final m5x1 = [
    [color.r],
    [color.g],
    [color.b],
    [1],
    [1],
  ];

  final result = _multiplyMatrix(m, m5x1);

  return [0, 1, 2]
      .map((e) => _clamp((result[e][0] * 255).round(), 0, 255))
      .toList();
}

num _clamp(num x, num min, num max) {
  return math.min(max, math.max(min, x));
}

/// Make the color adaptive with dark mode.
extension AdaptiveColorExt on Color {
  /// Transform into a more contrastive color on dark background.
  Color adaptiveDark() {
    final matrix = _multiplyMatrix(_identifiedMatrix, _invertNHueMatrix);
    final c1 = _applyColorMatrix(this, matrix);

    return Color.fromRGBO(c1[0] as int, c1[1] as int, c1[2] as int, 100);
  }
}
