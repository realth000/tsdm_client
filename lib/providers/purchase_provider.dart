import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';

part '../generated/providers/purchase_provider.g.dart';

extension _Regexp on String {
  String? matchValue() {
    final match = Purchase._valueRe.firstMatch(this);
    return match?.namedGroup('value');
  }

  String? matchAuthor() {
    final match = Purchase._authorRe.firstMatch(this);
    return match?.namedGroup('author');
  }

  String? matchCoins() {
    final match = Purchase._coinsRe.firstMatch(this);
    return match?.namedGroup('coins');
  }
}

@sealed
@immutable
class PurchaseResult {
  const PurchaseResult._();

  const factory PurchaseResult.success() = PurchaseSuccess;

  const factory PurchaseResult.failed(String message) = PurchaseFailed;
}

final class PurchaseSuccess extends PurchaseResult {
  const PurchaseSuccess() : super._();
}

final class PurchaseFailed extends PurchaseResult {
  const PurchaseFailed(this.message) : super._();

  final String message;
}

/// Info to check before purchasing.
class PurchaseConfirmInfo {
  PurchaseConfirmInfo({
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
  final String referer;
  final String tid;
  final String handleKey;
}

@Riverpod(dependencies: [NetClient])
class Purchase extends _$Purchase {
  static const _purchaseTarget =
      'https://tsdm39.com/forum.php?mod=misc&action=pay&paysubmit=yes&infloat=yes&inajax=1';
  static final _valueRe = RegExp(' value="(?<value>.+)" />');
  static final _authorRe = RegExp(r'<td><a.*>(?<author>.+)</a></td>');
  static final _coinsRe = RegExp(r'<td>(?<coins>\d+).*</td>');

  @override
  Future<void> build() async {}

  Future<PurchaseConfirmInfo?> conformBeforePurchase({
    required String tid,
    required String pid,
  }) async {
    final resp = await ref
        .read(NetClientProvider())
        .get(formatPurchaseDialogUrl(tid, pid));
    if (resp.statusCode != HttpStatus.ok) {
      // Network error.
      debug('fetch purchase dialog failed: code${resp.statusCode}');
      return null;
    }
    final dataList = (resp.data as String).split('\n');
    final inputList =
        dataList.where((e) => e.startsWith('<input type="hidden"')).toList();
    if (inputList.length != 4) {
      debug(
          'parse purchase dialog failed: invalid input length ${inputList.length}');
      return null;
    }
    final formHash = inputList[0].matchValue();
    final referer = inputList[1].matchValue();
    final tidInDialog = inputList[2].matchValue();
    final handleKey = inputList[3].matchValue();
    if (formHash == null ||
        referer == null ||
        tidInDialog == null ||
        handleKey == null) {
      debug(
          'parse purchase dialog failed: formHash=$formHash, referer=$referer, tid=$tidInDialog, handleKey=$handleKey');
      return null;
    }

    final tdList = dataList.where((e) => e.startsWith('<td>')).toList();
    if (tdList.length != 4) {
      debug('parse purchase dialog failed: invalid td length ${tdList.length}');
      return null;
    }

    final author = tdList[0].matchAuthor();
    final price = tdList[1].matchCoins();
    final authorProfit = tdList[2].matchCoins();
    final coinsLast = tdList[3].matchCoins();

    return PurchaseConfirmInfo(
      author: author,
      price: price,
      authorProfit: authorProfit,
      coinsLast: coinsLast,
      formHash: formHash,
      referer: referer,
      tid: tid,
      handleKey: handleKey,
    );
  }

  Future<PurchaseResult> purchase({
    required String formHash,
    required String referer,
    required String tid,
    required String handleKey,
  }) async {
    final body = {
      'formhash': formHash,
      'referer': referer,
      'tid': tid,
      'handlekey': handleKey,
    };
    final resp = await ref.read(NetClientProvider()).post(
          _purchaseTarget,
          data: body,
          options: Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          ),
        );

    if (resp.statusCode != HttpStatus.ok) {
      return PurchaseFailed('code=${resp.statusCode}');
    }

    if ((resp.data as String).contains('购买成功')) {
      return const PurchaseSuccess();
    }

    // TODO: Handle purchased failed reasons.
    return const PurchaseFailed('');
  }
}
