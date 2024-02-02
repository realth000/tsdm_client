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
}

/// 红包
final class PacketState extends Equatable {
  /// Constructor.
  const PacketState({
    this.status = PacketStatus.initial,
    this.reason,
  });

  /// Status.
  final PacketStatus status;

  /// Success reason or failed reason text.
  final String? reason;

  /// Copy with.
  PacketState copyWith({
    PacketStatus? status,
    String? reason,
  }) {
    return PacketState(
      status: status ?? this.status,
      reason: reason ?? this.reason,
    );
  }

  @override
  List<Object?> get props => [status, reason];
}
