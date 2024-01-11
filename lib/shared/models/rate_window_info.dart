import 'package:flutter/cupertino.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

/// A type of score in rate window.
///
/// Here the entire model assumes that:
/// * The first column of rate window table is score name.
/// * The second column is user selected value.
/// * The third column is allowed values.
/// * The forth last column is points remains today.
///
/// We can tell if here is other type of forms that have more or less than four
/// columns.
@immutable
final class RateWindowScore {
  const RateWindowScore({
    required this.id,
    required this.name,
    required this.allowedRange,
    required this.allowedRangeDescription,
    required this.remaining,
  });

  /// Score type:
  ///
  /// "score2" -> 天使币
  /// ("score3" -> 威望)
  /// "score4" -> 天然
  /// "score5" -> 腹黑
  final String id;

  /// Readable name in the first column.
  final String name;

  /// Allowed values.
  final List<String> allowedRange;

  /// Description of allowed range.
  final String allowedRangeDescription;

  /// Score that remaining to use in rate today.
  final String remaining;
}

@immutable
final class _RateWindowInfo {
  const _RateWindowInfo({
    required this.rowTitleList,
    required this.scoreList,
    required this.defaultReasonList,
    required this.formHash,
    required this.tid,
    required this.pid,
    required this.referer,
    required this.handleKey,
  });

  const _RateWindowInfo.empty()
      : rowTitleList = const [],
        scoreList = const [],
        defaultReasonList = const [],
        formHash = '',
        tid = '',
        pid = '',
        referer = '',
        handleKey = '';

  /// Row title of the rate table.
  /// The second value may be "&nbsp;" that need to be translated into whitespace.
  ///
  /// Expected title list:
  /// ["Factor 1", "&nbsp;", "评分区间", "今日剩余"]
  final List<String> rowTitleList;

  /// All types of scores that can rate.
  final List<RateWindowScore> scoreList;

  /// Default rate reason provided by server side.
  final List<String> defaultReasonList;

  /// Form data.
  final String formHash;
  final String tid;
  final String pid;
  final String referer;
  final String handleKey;
}

/// Information in rate confirm dialog window.
///
/// Used to post a rate action.
class RateWindowInfo {
  /// Build from <div class="c"> node [element] or from the floating window raw
  /// html.
  RateWindowInfo.fromDivCNode(uh.Element element)
      : _info = _buildFromDivCNode(element);

  final _RateWindowInfo _info;

  List<String> get rowTitleList => _info.rowTitleList;

  List<RateWindowScore> get scoreList => _info.scoreList;

  List<String> get defaultReasonList => _info.defaultReasonList;

  /// Form data
  String get tid => _info.tid;
  String get pid => _info.pid;
  String get formHash => _info.formHash;
  String get referer => _info.referer;
  String get handleKey => _info.handleKey;

  /// Build from <div class="c"> node [element] or from the floating window raw
  /// html.
  static _RateWindowInfo _buildFromDivCNode(uh.Element element) {
    // Parse table row title.

    // Rows in table.
    // The first element is row title.
    final rateTableRowsNodeList =
        element.querySelectorAll('table > tbody > tr').toList();

    // Should have at least one type of score to rate and also the row title as
    // list elements.
    if (rateTableRowsNodeList.length < 2) {
      debug(
          'invalid rate window info: incorrect rateTableRowsNodeList length: ${rateTableRowsNodeList.length}');
      return const _RateWindowInfo.empty();
    }

    // Length of row title list should be 4.
    final rowTitleList = rateTableRowsNodeList.firstOrNull
        ?.querySelectorAll('th')
        .map((e) => e.firstEndDeepText())
        .whereType<String>()
        .toList();
    // Explicitly check null here just make the compiler happy.
    if (rowTitleList == null || rowTitleList.length != 4) {
      debug(
          'invalid rate window info: incorrect rowTitleList length: ${rowTitleList?.length}');
      return const _RateWindowInfo.empty();
    }
    // Replace the second column title "&nbsp;" with whitespace.
    rowTitleList[1] = '';

    // Parse table score rows.

    final scoreList = rateTableRowsNodeList
        .skip(1)
        .map(_buildRateScoreRowFromTrNode)
        .whereType<RateWindowScore>()
        .toList();

    /// Score types available to rate should not be empty;
    if (scoreList.isEmpty) {
      debug('invalid rate score list: no available score types');
      return const _RateWindowInfo.empty();
    }

    // Parse default reasons.

    // Allow default reason list to be empty.
    final defaultReasonList = element
        .querySelector('div.tpclg ul#reasonselect')
        ?.querySelectorAll('li')
        .map((e) => e.firstEndDeepText())
        .whereType<String>()
        .toList();

    // Parse form data.
    final formHash =
        element.querySelector('input[name="formhash"]')?.attributes['value'];
    final tid = element.querySelector('input[name="tid"]')?.attributes['value'];
    final pid = element.querySelector('input[name="pid"]')?.attributes['value'];
    final referer =
        element.querySelector('input[name="referer"]')?.attributes['value'];
    final handleKey =
        element.querySelector('input[name="handlekey"]')?.attributes['value'];

    if (formHash == null ||
        tid == null ||
        pid == null ||
        referer == null ||
        handleKey == null) {
      debug(
          'invalid rate window info: invalid form data: formHash=$formHash, tid=$tid, pid=$pid, referer=$referer, handleKey=$handleKey');
      return const _RateWindowInfo.empty();
    }

    return _RateWindowInfo(
      rowTitleList: rowTitleList,
      scoreList: scoreList,
      defaultReasonList: defaultReasonList ?? [],
      formHash: formHash,
      tid: tid,
      pid: pid,
      referer: referer,
      handleKey: handleKey,
    );
  }

  /// Build a row of score to rate in rate table.
  static RateWindowScore? _buildRateScoreRowFromTrNode(uh.Element element) {
    final name = element.querySelector('td')?.firstEndDeepText();
    final id = element.querySelector('td:nth-child(2) > input')?.id;
    final allowedRange = element
        .querySelector('td:nth-child(2) > ul')
        ?.querySelectorAll('li')
        .map((e) => e.firstEndDeepText())
        .whereType<String>()
        .toList();
    final allowedRangeDescription =
        element.querySelector('td:nth-child(3)')?.firstEndDeepText();
    final remaining =
        element.querySelector('td:nth-child(4)')?.firstEndDeepText();
    if (name == null ||
        id == null ||
        allowedRange == null ||
        allowedRangeDescription == null ||
        remaining == null) {
      debug(
          'invalid rate score row: name=$name, id=$id, allowedRange=$allowedRange, allowedRangeDescription=$allowedRangeDescription');
      return null;
    }

    return RateWindowScore(
      name: name,
      id: id,
      allowedRange: allowedRange,
      allowedRangeDescription: allowedRangeDescription,
      remaining: remaining,
    );
  }

  bool isValid() {
    return rowTitleList.isNotEmpty && scoreList.isNotEmpty;
  }

  bool isNotValid() => !isValid();
}
