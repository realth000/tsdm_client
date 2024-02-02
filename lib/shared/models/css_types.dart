import 'dart:ui';

import 'package:equatable/equatable.dart';

/// Gather css types together.
///
/// Used when parsing css into flutter widget styles and themes.
class CssTypes extends Equatable {
  /// Constructor.
  const CssTypes({required this.fontWeight, required this.color});

  /// Font size converted from css.
  final FontWeight? fontWeight;

  /// Font color conveted from css.
  final Color? color;

  @override
  List<Object?> get props => [fontWeight, color];
}
