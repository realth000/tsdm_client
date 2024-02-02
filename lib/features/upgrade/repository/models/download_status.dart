import 'package:equatable/equatable.dart';

/// Model describes the download status.
class DownloadStatus extends Equatable {
  /// Constructor.
  const DownloadStatus({
    required this.recv,
    required this.total,
  });

  /// Recved bytes.
  final int recv;

  /// Total bytes.
  final int total;

  /// Download finished or not.
  bool get finished => recv == total;

  @override
  List<Object?> get props => [recv, total];
}
