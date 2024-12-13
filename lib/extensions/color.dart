import 'dart:ui';

/// Extension to provide color to int value ability as it was deprecated
/// since flutter 3.27
extension Accessor327Ext on Color {
  static int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  /// Accessor of color.value()
  ///
  /// ```dart
  /// A 32 bit value representing this color.
  ///
  /// The bits are assigned as follows:
  ///
  /// * Bits 24-31 are the alpha value.
  /// * Bits 16-23 are the red value.
  /// * Bits 8-15 are the green value.
  /// * Bits 0-7 are the blue value.
  /// @Deprecated('Use component accessors like .r or .g.')
  /// int get value {
  ///   return _floatToInt8(a) << 24 |
  ///   _floatToInt8(r) << 16 |
  ///   _floatToInt8(g) << 8 |
  ///   _floatToInt8(b) << 0;
  /// }
  /// ```
  int get valueA =>
      _floatToInt8(a) << 24 |
      _floatToInt8(r) << 16 |
      _floatToInt8(g) << 8 |
      _floatToInt8(b) << 0;

  /// Accessor of color.withOpacity also keeps precision.
  ///
  ///
  /// ```dart
  /// Returns a new color that matches this color with the alpha channel
  /// replaced with the given `opacity` (which ranges from 0.0 to 1.0).
  ///
  /// Out of range values will have unexpected effects.
  /// @Deprecated('Use .withValues() to avoid precision loss.')
  /// Color withOpacity(double opacity) {
  ///   assert(opacity >= 0.0 && opacity <= 1.0);
  ///   return withAlpha((255.0 * opacity).round());
  /// }
  /// ```
  Color withOpacityA(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0, 'invalid opacity value');
    return withValues(alpha: 255.0 * 0.3);
  }
}
