part of 'purchase_bloc.dart';

/// Status of purchase.
enum PurchaseStatus {
  /// Initial state.
  initial,

  /// Loading, maybe fetching confirm info or polling purchase request.
  loading,

  /// Already get purchase info.
  gotInfo,

  /// Purchase succeed.
  success,

  /// Failed to fetch confirm info or purchase.
  failed,
}

/// State of purchase.
final class PurchaseState extends Equatable {
  /// Constructor.
  const PurchaseState({
    this.status = PurchaseStatus.initial,
    this.confirmInfo,
  });

  /// Status.
  final PurchaseStatus status;

  /// MUST get this info before purchase.
  final PurchaseConfirmInfo? confirmInfo;

  /// Copy with.
  PurchaseState copyWith({
    PurchaseStatus? status,
    PurchaseConfirmInfo? confirmInfo,
  }) {
    return PurchaseState(
      status: status ?? this.status,
      confirmInfo: confirmInfo ?? this.confirmInfo,
    );
  }

  @override
  List<Object?> get props => [status, confirmInfo];
}
