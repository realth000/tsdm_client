import 'package:equatable/equatable.dart';

class DownloadStatus extends Equatable {
  const DownloadStatus({
    required this.recv,
    required this.total,
  });

  final int recv;
  final int total;

  bool get finished => recv == total;

  @override
  List<Object?> get props => [recv, total];
}
