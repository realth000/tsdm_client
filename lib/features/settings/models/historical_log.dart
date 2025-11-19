import 'dart:io';

/// Log file.
final class HistoricalLog {
  /// Constructor.
  const HistoricalLog(this.time, this.file);

  /// Time of the log, in days.
  final DateTime time;

  /// File entity to the log file.
  final File file;
}
