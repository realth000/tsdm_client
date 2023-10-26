extension DateTimeExtension on DateTime {
  String yyyyMMDD() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  String elapsedTillNow() {
    final duration = DateTime.now().difference(this);
    return duration.inDays > 0
        ? '${duration.inDays}天以前'
        : duration.inHours > 0
            ? '${duration.inHours}小时以前'
            : duration.inMinutes > 0
                ? '${duration.inMinutes}分钟以前'
                : '${duration.inSeconds}秒以前';
  }
}
