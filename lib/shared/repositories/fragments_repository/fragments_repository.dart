import 'dart:ui';

/// Repository stores tiny fragments of states as global values.
///
/// **CAUTION**
///
/// * All the states in this repo should be used by single "user" of app.
class FragmentsRepository {
  /// Constructor.
  FragmentsRepository({
    this.topicsPageTabIndex = 0,
    this.settingsPageScrollOffset = Offset.zero,
  });

  /// Home tab index.
  int topicsPageTabIndex;

  /// Scroll offset in settings page.
  Offset settingsPageScrollOffset;
}
