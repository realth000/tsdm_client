part of 'packet_cubit.dart';

enum PacketStatus {
  initial,
  loading,
  success,
  failed,
}

/// 红包
final class PacketState extends Equatable {
  const PacketState({
    this.status = PacketStatus.initial,
    this.reason,
  });

  final PacketStatus status;

  /// Success reason or failed reason text.
  final String? reason;

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
