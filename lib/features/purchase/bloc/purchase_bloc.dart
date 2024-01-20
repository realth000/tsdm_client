import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/purchase/exceptions/exceptions.dart';
import 'package:tsdm_client/features/purchase/models/purchase_confirm_info.dart';
import 'package:tsdm_client/features/purchase/repository/purchase_repository.dart';
import 'package:tsdm_client/utils/debug.dart';

part 'purchase_event.dart';
part 'purchase_state.dart';

typedef PurchaseEmitter = Emitter<PurchaseState>;

final class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
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
    try {
      final confirmInfo = await _purchaseRepository.fetchPurchaseConfirmInfo(
          tid: event.tid, pid: event.pid);
      emit(state.copyWith(
          status: PurchaseStatus.gotInfo, confirmInfo: confirmInfo));
    } on HttpRequestFailedException catch (e) {
      debug('failed to fetch purchase info: $e');
      emit(state.copyWith(status: PurchaseStatus.failed));
      return;
    } on PurchaseInfoInvalidParameterCountException catch (e) {
      debug('failed to fetch purchase info: $e');
      emit(state.copyWith(status: PurchaseStatus.failed));
      return;
    } on PurchaseInfoIncompleteException catch (e) {
      debug('failed to fetch purchase info: $e');
      emit(state.copyWith(status: PurchaseStatus.failed));
      return;
    } on PurchaseInfoInvalidNoticeException catch (e) {
      debug('failed to fetch purchase info: $e');
      emit(state.copyWith(status: PurchaseStatus.failed));
      return;
    }
  }

  Future<void> _onPurchasePurchaseRequested(
    PurchasePurchaseRequested event,
    PurchaseEmitter emit,
  ) async {
    if (state.confirmInfo == null) {
      debug('failed to purchase: confirm info not prepared');
      emit(state.copyWith(status: PurchaseStatus.failed));
      return;
    }
    emit(state.copyWith(status: PurchaseStatus.loading));

    final confirmInfo = state.confirmInfo!;

    try {
      await _purchaseRepository.purchase(
        formHash: confirmInfo.formHash,
        referer: confirmInfo.referer,
        handleKey: confirmInfo.handleKey,
        tid: confirmInfo.tid,
      );
      emit(state.copyWith(status: PurchaseStatus.success));
    } on HttpRequestFailedException catch (e) {
      debug('failed to purchase: $e');
      emit(state.copyWith(status: PurchaseStatus.failed));
      return;
    } on PurchaseActionFailedException catch (e) {
      debug('failed to purchase: $e');
      emit(state.copyWith(status: PurchaseStatus.failed));
      return;
    }
  }

  Future<void> _onPurchasePurchasedCanceled(
    PurchasePurchasedCanceled event,
    PurchaseEmitter emit,
  ) async {
    emit(state.copyWith(status: PurchaseStatus.initial));
  }
}
