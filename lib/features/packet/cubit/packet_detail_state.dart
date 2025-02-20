part of 'packet_detail_cubit.dart';

/// Basic state
@MappableClass()
sealed class PacketDetailState with PacketDetailStateMappable {
  /// Constructor.
  const PacketDetailState();
}

/// Initial state.
@MappableClass()
final class PacketDetailInitial extends PacketDetailState with PacketDetailInitialMappable {}

/// Loading packet detail data
@MappableClass()
final class PacketDetailLoading extends PacketDetailState with PacketDetailLoadingMappable {}

/// Loaded data successfully
@MappableClass()
final class PacketDetailSuccess extends PacketDetailState with PacketDetailSuccessMappable {
  /// Constructor.
  const PacketDetailSuccess(this.data);

  /// Fetched data.
  final List<PacketDetailModel> data;
}

/// Failed to load packet statistics data.
@MappableClass()
final class PacketDetailFailure extends PacketDetailState with PacketDetailFailureMappable {}
