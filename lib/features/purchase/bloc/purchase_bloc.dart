import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/purchase/models/models.dart';
import 'package:tsdm_client/features/purchase/repository/purchase_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'purchase_bloc.mapper.dart';
part 'purchase_event.dart';
part 'purchase_state.dart';

/// Emitter
typedef PurchaseEmitter = Emitter<PurchaseState>;

/// Bloc of purchasing.
final class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> with LoggerMixin {
  /// Constructor.
  PurchaseBloc({required PurchaseRepository purchaseRepository})
    : _purchaseRepository = purchaseRepository,
      super(const PurchaseState()) {
    on<PurchaseFetchConfirmInfoRequested>(_onPurchaseFetchConfirmInfoRequested);
    on<PurchasePurchaseRequested>(_onPurchasePurchaseRequested);
    on<PurchasePurchasedCanceled>(_onPurchasePurchasedCanceled);
  }

  final PurchaseRepository _purchaseRepository;

  Future<void> _onPurchaseFetchConfirmInfoRequested(
    PurchaseFetchConfirmInfoRequested event,
    PurchaseEmitter emit,
  ) async {
    emit(state.copyWith(status: PurchaseStatus.loading));
    await _purchaseRepository.fetchPurchaseConfirmInfo(tid: event.tid, pid: event.pid).match((e) {
      handle(e);
      error('failed to fetch purchase info: $e');
      emit(state.copyWith(status: PurchaseStatus.failed));
    }, (v) => emit(state.copyWith(status: PurchaseStatus.gotInfo, confirmInfo: v))).run();
  }

  Future<void> _onPurchasePurchaseRequested(PurchasePurchaseRequested event, PurchaseEmitter emit) async {
    if (state.confirmInfo == null) {
      error('failed to purchase: confirm info not prepared');
      emit(state.copyWith(status: PurchaseStatus.failed));
      return;
    }
    emit(state.copyWith(status: PurchaseStatus.loading));

    final confirmInfo = state.confirmInfo!;

    try {
      await _purchaseRepository
          .purchase(
            formHash: confirmInfo.formHash,
            referer: confirmInfo.referer,
            handleKey: confirmInfo.handleKey,
            tid: confirmInfo.tid,
          )
          .run();
      emit(state.copyWith(status: PurchaseStatus.success));
    } on HttpRequestFailedException catch (e) {
      error('failed to purchase: $e');
      emit(state.copyWith(status: PurchaseStatus.failed));
      return;
    } on PurchaseActionFailedException catch (e) {
      error('failed to purchase: $e');
      emit(state.copyWith(status: PurchaseStatus.failed));
      return;
    }
  }

  Future<void> _onPurchasePurchasedCanceled(PurchasePurchasedCanceled event, PurchaseEmitter emit) async {
    emit(state.copyWith(status: PurchaseStatus.initial));
  }
}
