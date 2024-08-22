import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/features/packet/repository/packet_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'packet_cubit.mapper.dart';
part 'packet_state.dart';

/// Cubit of read packets.
class PacketCubit extends Cubit<PacketState> with LoggerMixin {
  /// Constructor.
  PacketCubit({required PacketRepository packetRepository})
      : _packetRepository = packetRepository,
        super(const PacketState());

  final PacketRepository _packetRepository;

  /// Try to get coins from the packet.
  Future<void> receivePacket(String url) async {
    emit(state.copyWith(status: PacketStatus.loading));
    await _packetRepository.receivePacket(url).match((e) {
      handle(e);

      error('failed to receive packet: $e');
      emit(
        state.copyWith(
          status: PacketStatus.failed,
          reason: e.toString(),
        ),
      );
    }, (v) {
      final document = v;
      final result = document
          .querySelector('div#messagetext > p')
          ?.innerText
          .split('setTimeout')
          .firstOrNull;
      if (result != null &&
          (result.contains('已经领取过') || result.contains('领取成功'))) {
        emit(state.copyWith(status: PacketStatus.success, reason: result));
      } else if (result != null &&
          result.contains('err_packet_has_gone_away')) {
        emit(state.copyWith(status: PacketStatus.takenAway));
      } else {
        emit(state.copyWith(status: PacketStatus.failed, reason: result));
      }
    }).run();
  }
}
