/// Font size.
/// Only works for tsdm.
///
/// In the text editor, only 1 - 7 sizes are used.
/// Font height can be known by hovering on html element in the devtool viewer.
/// Normal text size is 18px.
enum FontSize {
  /// "1": 11px
  size1,

  /// "2": 14px
  size2,

  /// "3": 17px
  size3,

  /// "4": 19px
  size4,

  /// "5": 25px
  size5,

  /// "6": 33px
  size6,

  /// "7": 49px
  size7,

  /// Not support size.
  notSupport;

  factory FontSize.fromString(String? size) {
    if (size == null) {
      return FontSize.notSupport;
    }

    return switch (size) {
      '1' => FontSize.size1,
      '2' => FontSize.size2,
      '3' => FontSize.size3,
      '4' => FontSize.size4,
      '5' => FontSize.size5,
      '6' => FontSize.size6,
      '7' => FontSize.size7,
      String() => FontSize.notSupport,
    };
  }

  /// Return the font size value.
  double value() {
    return switch (this) {
      FontSize.size1 => 11.0,
      FontSize.size2 => 14.0,
      FontSize.size3 => 17.0,
      FontSize.size4 => 19.0,
      FontSize.size5 => 25.0,
      FontSize.size6 => 33.0,
      FontSize.size7 => 49.0,
      FontSize.notSupport => 18.0, // Default is 18
    };
  }

  /// Is the font size valid.
  bool get isValid => this != FontSize.notSupport;

  /// Is the font size invalid.
  bool get isNotValid => !isValid;
}
