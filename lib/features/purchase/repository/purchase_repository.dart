import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/purchase/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

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

/// Repository of purchasing.
final class PurchaseRepository with LoggerMixin {
  static const _purchaseTarget =
      'https://tsdm39.com/forum.php?mod=misc&action=pay&paysubmit=yes&infloat=yes&inajax=1';
  static final _valueRe = RegExp(' value="(?<value>.+)" />');
  static final _authorRe = RegExp('<td><a.*>(?<author>.+)</a></td>');
  static final _coinsRe = RegExp(r'<td>(?<coins>\d+).*</td>');

  /// Fetch confirm info before purchase post [pid] in thread [tid].
  ///
  /// MUST call this function before purchase.
  AsyncEither<PurchaseConfirmInfo> fetchPurchaseConfirmInfo({
    required String tid,
    required String pid,
  }) =>
      AsyncEither(() async {
        final resp = await getIt
            .get<NetClientProvider>()
            .get(formatPurchaseDialogUrl(tid, pid));
        if (resp.statusCode != HttpStatus.ok) {
          // Network error.
          error('fetch purchase dialog failed: code${resp.statusCode}');
          return left(HttpRequestFailedException(resp.statusCode));
        }
        final dataList = (resp.data as String).split('\n');
        final inputList = dataList
            .where((e) => e.startsWith('<input type="hidden"'))
            .toList();
        if (inputList.length != 4) {
          error(
            'parse purchase dialog failed: invalid input length '
            '${inputList.length}',
          );
          return left(PurchaseInfoInvalidParameterCountException());
        }
        final formHash = inputList[0].matchValue();
        final referer = inputList[1].matchValue();
        final tidInDialog = inputList[2].matchValue();
        final handleKey = inputList[3].matchValue();
        if (formHash == null ||
            referer == null ||
            tidInDialog == null ||
            handleKey == null) {
          error(
            'parse purchase dialog failed: formHash=$formHash, '
            'referer=$referer, tid=$tidInDialog, handleKey=$handleKey',
          );
          return left(PurchaseInfoIncompleteException());
        }

        final tdList = dataList.where((e) => e.startsWith('<td>')).toList();
        if (tdList.length != 4) {
          error('parse purchase dialog failed: invalid td '
              'length ${tdList.length}');
          return left(PurchaseInfoInvalidNoticeException());
        }

        final author = tdList[0].matchAuthor();
        final price = tdList[1].matchCoins();
        final authorProfit = tdList[2].matchCoins();
        final coinsLast = tdList[3].matchCoins();
        return right(
          PurchaseConfirmInfo(
            author: author,
            price: price,
            authorProfit: authorProfit,
            coinsLast: coinsLast,
            formHash: formHash,
            referer: referer,
            tid: tid,
            handleKey: handleKey,
          ),
        );
      });

  /// Purchase with given parameters.
  AsyncVoidEither purchase({
    required String formHash,
    required String referer,
    required String tid,
    required String handleKey,
  }) =>
      AsyncVoidEither(() async {
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
          return left(HttpRequestFailedException(resp.statusCode));
        }

        if (!(resp.data as String).contains('购买成功')) {
          return left(PurchaseActionFailedException());
        }
        return rightVoid();
      });
}
