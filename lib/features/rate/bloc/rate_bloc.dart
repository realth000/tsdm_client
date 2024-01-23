import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/rate/models/rate_window_info.dart';
import 'package:tsdm_client/features/rate/repository/exceptions/exceptions.dart';
import 'package:tsdm_client/features/rate/repository/rate_repository.dart';
import 'package:tsdm_client/utils/debug.dart';

part 'rate_event.dart';
part 'rate_state.dart';

typedef RateEmitter = Emitter<RateState>;

final class RateBloc extends Bloc<RateEvent, RateState> {
  RateBloc({required RateRepository rateRepository})
      : _rateRepository = rateRepository,
        super(const RateState()) {
    on<RateFetchInfoRequested>(_onRateFetchInfoRequested);
    on<RateRateRequested>(_onRateRateRequested);
  }

  final RateRepository _rateRepository;

  Future<void> _onRateFetchInfoRequested(
    RateFetchInfoRequested event,
    RateEmitter emit,
  ) async {
    emit(state.copyWith(status: RateStatus.fetchingInfo));
    try {
      final rateInfo = await _rateRepository.fetchInfo(
          pid: event.pid, rateTarget: event.rateAction);
      emit(state.copyWith(status: RateStatus.gotInfo, info: rateInfo));
    } on HttpRequestFailedException catch (e) {
      debug('failed to fetch rate info: $e');
      emit(state.copyWith(status: RateStatus.failed));
    } on RateInfoWithErrorException catch (e) {
      debug('failed to fetch rate info: $e');
      // Do NOT retry if server returns an error.
      emit(state.copyWith(
        status: RateStatus.failed,
        failedReason: e.message,
        shouldRetry: false,
      ));
    } on RateInfoException catch (e) {
      debug('failed to fetch rate info: $e');
      emit(state.copyWith(
          status: RateStatus.failed, failedReason: e.toString()));
    }
  }

  Future<void> _onRateRateRequested(
    RateRateRequested event,
    RateEmitter emit,
  ) async {
    emit(state.copyWith(status: RateStatus.rating));
    try {
      await _rateRepository.rate(event.rateInfo);
      emit(state.copyWith(status: RateStatus.success));
    } on HttpRequestFailedException catch (e) {
      debug('failed to rate: $e');
      emit(state.copyWith(status: RateStatus.failed));
    } on RateFailedException catch (e) {
      emit(state.copyWith(status: RateStatus.failed, failedReason: e.reason));
    }
  }
}
