import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/rate/models/models.dart';
import 'package:tsdm_client/features/rate/repository/rate_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'rate_bloc.mapper.dart';
part 'rate_event.dart';

part 'rate_state.dart';

/// Emitter
typedef RateEmitter = Emitter<RateState>;

/// Bloc to rate.
final class RateBloc extends Bloc<RateEvent, RateState> with LoggerMixin {
  /// Constructor.
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
    await _rateRepository
        .fetchInfo(
      pid: event.pid,
      rateTarget: event.rateAction,
    )
        .match(
      (e) {
        handle(e);
        if (e case HttpRequestFailedException()) {
          error('failed to fetch rate info: $e');
          emit(state.copyWith(status: RateStatus.failed));
        } else if (e case RateInfoWithErrorException()) {
          error('failed to fetch rate info: $e');
          // Do NOT retry if server returns an error.
          emit(
            state.copyWith(
              status: RateStatus.failed,
              failedReason: e.message,
              shouldRetry: false,
            ),
          );
        } else if (e case RateInfoException()) {
          error('failed to fetch rate info: $e');
          emit(
            state.copyWith(
              status: RateStatus.failed,
              failedReason: e.toString(),
            ),
          );
        } else {
          emit(state.copyWith(status: RateStatus.failed));
        }
      },
      (v) => emit(state.copyWith(status: RateStatus.gotInfo, info: v)),
    ).run();
  }

  Future<void> _onRateRateRequested(
    RateRateRequested event,
    RateEmitter emit,
  ) async {
    emit(state.copyWith(status: RateStatus.rating));

    await _rateRepository.rate(event.rateInfo).match(
      (e) {
        handle(e);
        error('failed to rate: $e');
        emit(state.copyWith(status: RateStatus.failed));
      },
      (v) => emit(state.copyWith(status: RateStatus.success)),
    ).run();
  }
}
