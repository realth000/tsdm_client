import 'dart:io';

import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/purchase/exceptions/exceptions.dart';
import 'package:tsdm_client/features/purchase/models/purchase_confirm_info.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';

extension _Regexp on String {
  String? matchValue() {
    final match = PurchaseRepository._valueRe.firstMatch(this);
    return match?.namedGroup('value');
  }

  String? matchAuthor() {
    final match = PurchaseRepository._authorRe.firstMatch(this);
    return match?.namedGroup('author');
  }

  String? matchCoins() {
    final match = PurchaseRepository._coinsRe.firstMatch(this);
    return match?.namedGroup('coins');
  }
}

class PurchaseRepository {
  static const _purchaseTarget =
      'https://tsdm39.com/forum.php?mod=misc&action=pay&paysubmit=yes&infloat=yes&inajax=1';
  static final _valueRe = RegExp(' value="(?<value>.+)" />');
  static final _authorRe = RegExp(r'<td><a.*>(?<author>.+)</a></td>');
  static final _coinsRe = RegExp(r'<td>(?<coins>\d+).*</td>');

  /// Fetch confirm info before purchase post [pid] in thread [tid].
  ///
  /// MUST call this function before purchase.
  ///
  /// # Exception
  ///
  /// * **HttpRequestFailedException** when http request failed.
  ///
  /// # Sealed Exception
  ///
  /// * **PurchaseInfoInvalidParameterCountException** when fetched parameter count
  ///   in confirm info window is incorrect.
  /// * **PurchaseInfoIncompleteException** when fetched confirm info
  ///   parameter is incomplete.
  /// * **PurchaseInfoInvalidNoticeException** when confirm info to display
  ///   (including price, thread author) is invalid.
  Future<PurchaseConfirmInfo> fetchPurchaseConfirmInfo({
    required String tid,
    required String pid,
  }) async {
    final resp = await getIt
        .get<NetClientProvider>()
        .get(formatPurchaseDialogUrl(tid, pid));
    if (resp.statusCode != HttpStatus.ok) {
      // Network error.
      debug('fetch purchase dialog failed: code${resp.statusCode}');
      throw HttpRequestFailedException(resp.statusCode!);
    }
    final dataList = (resp.data as String).split('\n');
    final inputList =
        dataList.where((e) => e.startsWith('<input type="hidden"')).toList();
    if (inputList.length != 4) {
      debug(
          'parse purchase dialog failed: invalid input length ${inputList.length}');
      throw PurchaseInfoInvalidParameterCountException();
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
      throw PurchaseInfoIncompleteException();
    }

    final tdList = dataList.where((e) => e.startsWith('<td>')).toList();
    if (tdList.length != 4) {
      debug('parse purchase dialog failed: invalid td length ${tdList.length}');
      throw PurchaseInfoInvalidNoticeException();
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

  /// Purchase with given parameters.
  ///
  /// # Exception
  ///
  /// * **HttpRequestFailedException** when http request failed.
  /// * **PurchaseActionFailedException** when purchase action failed.
  Future<void> purchase({
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
    final resp = await getIt
        .get<NetClientProvider>()
        .postForm(_purchaseTarget, data: body);

    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }

    if (!(resp.data as String).contains('购买成功')) {
      throw PurchaseActionFailedException();
    }
  }
}
