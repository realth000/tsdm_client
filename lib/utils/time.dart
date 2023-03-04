/// Format:
///
/// "2023-3-4" -> "2023-03-04"
/// "2023-10-1" -> "2023-10-01"
/// "2023-3-4 00:11:22" -> "2023-03-03 00:11:22"
String formatTimeString(String timeString) {
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
      ? formattedDateString
      : '$formattedDateString $hourString';
}
