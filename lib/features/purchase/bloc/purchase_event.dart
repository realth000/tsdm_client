part of 'purchase_bloc.dart';

/// Event of purchase.
@MappableClass()
sealed class PurchaseEvent with PurchaseEventMappable {
  const PurchaseEvent();
}

/// Require the user to confirm related purchase info.
///
/// Should do this before the purchase action.
@MappableClass()
final class PurchaseFetchConfirmInfoRequested extends PurchaseEvent
    with PurchaseFetchConfirmInfoRequestedMappable {
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
@MappableClass()
final class PurchasePurchaseRequested extends PurchaseEvent
    with PurchasePurchaseRequestedMappable {}

/// User required to cancel the purchase.
///
/// This is likely to trigger by closing the confirm dialog.
@MappableClass()
final class PurchasePurchasedCanceled extends PurchaseEvent
    with PurchasePurchasedCanceledMappable {}
