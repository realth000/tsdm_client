part of 'models.dart';

/// The model of fast rating.
@MappableClass()
final class FastRateTemplateModel with FastRateTemplateModelMappable {
  /// Constructor.
  const FastRateTemplateModel({
    required this.name,
    required this.ww,
    required this.tsb,
    required this.xc,
    required this.tr,
    required this.fh,
    required this.jl,
    required this.special,
    required this.special2,
  });

  /// Name of template.
  final String name;

  /// Attribute 威望
  final int ww;

  /// Attribute 天使币
  final int tsb;

  /// Attribute 宣传
  final int xc;

  /// Attribute 天然
  final int tr;

  /// Attribute 腹黑
  final int fh;

  /// Attribute 精灵
  final int jl;

  /// Special attribute.
  final int special;

  /// Another special attribute.
  final int special2;
}
