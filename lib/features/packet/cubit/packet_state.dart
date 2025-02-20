part of 'packet_cubit.dart';

/// Status of receiving packets.
enum PacketStatus {
  /// Initial.
  initial,

  /// Loading data.
  loading,

  /// Load succeed.
  success,

  /// Load failed.
  failed,

  /// All packets were taken away.
  takenAway,
}

/// 红包
@MappableClass()
final class PacketState with PacketStateMappable {
  /// Constructor.
  const PacketState({this.status = PacketStatus.initial, this.reason});

  /// Status.
  final PacketStatus status;

  /// Success reason or failed reason text.
  final String? reason;
}
