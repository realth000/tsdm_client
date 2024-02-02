part of 'purchase_bloc.dart';

/// Event of purchase.
sealed class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object?> get props => [];
}

/// Require the user to confirm related purchase info.
///
/// Should do this before the purchase acition.
final class PurchaseFetchConfirmInfoRequested extends PurchaseEvent {
  /// Constructor.
  const PurchaseFetchConfirmInfoRequested({
    required this.tid,
    required this.pid,
  }) : super();

  /// Thread id to purchase.
  final String tid;

  /// Post id to purchase.
  final String pid;
}

/// User requested to purchase.
///
/// Should let user confirmed the info related to purchasing.
final class PurchasePurchaseRequested extends PurchaseEvent {}

/// User required to cancel the purchase.
///
/// This is likely to trigger by closing the confirm dialog.
final class PurchasePurchasedCanceled extends PurchaseEvent {}
