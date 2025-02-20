import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/features/packet/models/models.dart';
import 'package:tsdm_client/features/packet/repository/packet_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'packet_detail_cubit.mapper.dart';
part 'packet_detail_state.dart';

/// Cubit of packet detail.
///
/// Recording the process state of fetching packet statistics detail data of a
/// given thread.
final class PacketDetailCubit extends Cubit<PacketDetailState> with LoggerMixin {
  /// Constructor.
  PacketDetailCubit(this._repo) : super(PacketDetailInitial());

  final PacketRepository _repo;

  /// Fetch packet statistics detail data of a thread [tid].
  ///
  /// # CAUTION
  ///
  /// The caller MUST ensure thread [tid] has a packet.
  Future<void> fetchDetail(int tid) async {
    emit(PacketDetailLoading());
    switch (await _repo.fetchDetail(tid).run()) {
      case Left(:final value):
        handle(value);
        emit(PacketDetailFailure());
      case Right(:final value):
        emit(PacketDetailSuccess(value));
    }
  }
}
