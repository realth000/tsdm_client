/// Extension of [DateTime] that provides some transformation and calculation.
extension DateTimeExtension on DateTime {
  /// Format [DateTime] to format yyyy-MM-DD.
  String yyyyMMDD() {
    return '$year-${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }

  /// Format [DateTime] to format yyyy-MM-DD hh:mm:ss
  String yyyyMMDDHHMMSS() {
    return '$year-${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')} ${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:'
        '${second.toString().padLeft(2, '0')}';
  }

  /// Calculate the duration to current date time.
  ///
  /// May be less than zero if current time is older than the given `this` time.
  String elapsedTillNow() {
    final duration = DateTime.now().difference(this);
    return duration.inDays > 0
        ? '${duration.inDays}天'
        : duration.inHours > 0
            ? '${duration.inHours}小时'
            : duration.inMinutes > 0
                ? '${duration.inMinutes}分钟'
                : '${duration.inSeconds}秒';
  }
}
