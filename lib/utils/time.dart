/// Format:
///
/// "2023-3-4" -> "2023-03-04T00:00:00+08:00"
/// "2023-10-1" -> "2023-10-01T00:00:00+08:00"
/// "2023-3-4 00:11:22" -> "2023-03-03T00:11:22+08:00"
String formatTimeStringWithUTC8(String timeString) {
  final timePartList = timeString.split(' ');
  late final String dateString;
  String? hourString;
  if (timePartList.length == 2) {
    dateString = timePartList[0];
    hourString = timePartList[1];
  } else {
    dateString = timePartList[0];
  }
  final datePartList = dateString.split('-');
  if (datePartList.length != 3) {
    // Should not happen.
    return timeString;
  }
  final formattedDateString =
      '${datePartList[0]}-${datePartList[1].padLeft(2, '0')}-${datePartList[2].padLeft(2, '0')}';
  return hourString == null
      ? '${formattedDateString}T00:00:00+08:00'
      : '${formattedDateString}T$hourString+08:00';
}

/// Return [older] "how long time ago" relative to [newer].
String timeDifferenceToString(DateTime newer, DateTime older) {
  final duration = newer.difference(older);
  return duration.inDays > 0
      ? '${duration.inDays}天以前'
      : duration.inHours > 0
          ? '${duration.inHours}小时以前'
          : duration.inMinutes > 0
              ? '${duration.inMinutes}分钟以前'
              : '${duration.inSeconds}秒以前';
}
