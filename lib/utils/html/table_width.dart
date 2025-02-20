import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Custom [Table] column width based on[IntrinsicColumnWidth].
///
/// Added:
///
/// 1. Padding in each cell. (not yet) // TODO: implement padding
/// 2. Max column width.
///
/// Original comments:
///
/// Sizes the column according to the intrinsic dimensions of all the
/// cells in that column.
///
/// This is a very expensive way to size a column.
///
/// A flex value can be provided. If specified (and non-null), the
/// column will participate in the distribution of remaining space
/// once all the non-flexible columns have been sized.
class MaxIntrinsicColumnWidth extends TableColumnWidth {
  /// Creates a column width based on intrinsic sizing.
  ///
  /// This sizing algorithm is very expensive.
  ///
  /// The `flex` argument specifies the flex factor to apply to the column if
  /// there is any room left over when laying out the table. If `flex` is
  /// null (the default), the table will not distribute any extra space to the
  /// column.
  const MaxIntrinsicColumnWidth({double? flex, this.maxWidth}) : _flex = flex;

  /// Maximum width on each column.
  ///
  /// Set this value to constrains max horizontal width.
  final double? maxWidth;

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    var result = 0.0;
    if (maxWidth != null) {
      for (final cell in cells) {
        final double constrainedWidth;
        constrainedWidth = math.min(cell.getMinIntrinsicWidth(double.infinity), maxWidth!);
        result = math.max(result, constrainedWidth);
      }
    } else {
      for (final cell in cells) {
        result = math.max(result, cell.getMinIntrinsicWidth(double.infinity));
      }
    }
    return result;
  }

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    var result = 0.0;
    if (maxWidth != null) {
      for (final cell in cells) {
        final double constrainedWidth;
        constrainedWidth = math.min(cell.getMaxIntrinsicWidth(double.infinity), maxWidth!);
        result = math.max(result, constrainedWidth);
      }
    } else {
      for (final cell in cells) {
        result = math.max(result, cell.getMaxIntrinsicWidth(double.infinity));
      }
    }
    return result;
  }

  final double? _flex;

  @override
  double? flex(Iterable<RenderBox> cells) => _flex;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'MaxIntrinsicColumnWidth')}'
      '(flex: ${_flex?.toStringAsFixed(1)})';
}
