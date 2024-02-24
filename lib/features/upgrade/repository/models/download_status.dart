part of 'models.dart';

/// Model describes the download status.
@MappableClass()
class DownloadStatus with DownloadStatusMappable {
  /// Constructor.
  const DownloadStatus({
    required this.recv,
    required this.total,
  });

  /// Received bytes.
  final int recv;

  /// Total bytes.
  final int total;

  /// Download finished or not.
  bool get finished => recv == total;
}
