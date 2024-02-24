part of 'models.dart';

/// Gather css types together.
///
/// Used when parsing css into flutter widget styles and themes.
@MappableClass()
class CssTypes with CssTypesMappable {
  /// Constructor.
  const CssTypes({required this.fontWeight, required this.color});

  /// Font size converted from css.
  final FontWeight? fontWeight;

  /// Font color converted from css.
  final Color? color;
}
