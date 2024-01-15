import 'dart:ui';

import 'package:equatable/equatable.dart';

class CssTypes extends Equatable {
  const CssTypes({required this.fontWeight, required this.color});

  final FontWeight? fontWeight;
  final Color? color;

  @override
  List<Object?> get props => [fontWeight, color];
}
