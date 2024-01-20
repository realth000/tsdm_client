part of 'purchase_bloc.dart';

sealed class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object?> get props => [];
}

final class PurchaseFetchConfirmInfoRequested extends PurchaseEvent {
  const PurchaseFetchConfirmInfoRequested({
    required this.tid,
    required this.pid,
  }) : super();

  final String tid;
  final String pid;
}

final class PurchasePurchaseRequested extends PurchaseEvent {}

final class PurchasePurchasedCanceled extends PurchaseEvent {}
