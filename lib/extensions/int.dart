import 'dart:math' as math;

/// The extensions methods on int type.
extension IntExt on int {
  static const _suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];

  /// Add size hint after the value.
  String withSizeHint() {
    if (this <= 0) {
      return '0 ${_suffixes.first}';
    }
    final i = (math.log(this) / math.log(1024)).floor();
    return '${(this / math.pow(1024, i)).toStringAsFixed(2)} ${_suffixes[i]}';
  }
}
