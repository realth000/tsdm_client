import 'package:equatable/equatable.dart';

/// Info to check before purchasing.
class PurchaseConfirmInfo extends Equatable {
  /// Constructor.
  const PurchaseConfirmInfo({
    required this.author,
    required this.price,
    required this.authorProfit,
    required this.coinsLast,
    required this.formHash,
    required this.referer,
    required this.tid,
    required this.handleKey,
  });

  /// Author name
  final String? author;

  /// Price.
  final String? price;

  /// How many coins the author will get.
  final String? authorProfit;

  /// How many coins last after purchase.
  final String? coinsLast;

  /// Data used in purchasing.
  final String formHash;

  /// Referer parameter in request.
  final String referer;

  /// Thread id.
  final String tid;

  /// Handle key parameter in request.
  final String handleKey;

  @override
  List<Object?> get props => [
        author,
        price,
        authorProfit,
        coinsLast,
        formHash,
        referer,
        tid,
        handleKey,
      ];
}
