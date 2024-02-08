import 'package:equatable/equatable.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

/// Describe the change is lifting points up or down.
///
enum PointsChangeType {
  /// Points become more.
  more,

  /// Points become less.
  less,

  /// Unknown change type.
  ///
  /// We do not know the points become more or less.
  ///
  /// Use as a fallback type.
  unknown,
}

/// A single change on the user's points.
///
/// Contains of change operation, attr points change list, change detail and
/// happened datetime.
class PointsChange extends Equatable {
  /// Constructor
  const PointsChange({
    required this.operation,
    required this.operationFilterUrl,
    required this.pointsChangeType,
    required this.changeMap,
    required this.detail,
    required this.time,
    this.redirectUrl,
  });

  /// Operation type of this change.
  final String operation;

  /// Url to show the filter result of same type operation in points changelog.
  final String operationFilterUrl;

  /// Map of the changes in different attr types with their names and values.
  final Map<String, String> changeMap;

  /// Describe how the change effect the user's points: lift up or down.
  ///
  /// # Caution
  ///
  /// This section is detected by the change type on the first kind of points
  /// in the changelog, we  assume that the whole change type is always the same
  /// with that of the first one.
  final PointsChangeType pointsChangeType;

  /// Html node to parse the detail change.
  final String detail;

  /// An url to redirect.
  ///
  /// Point changes usually have this, but not guaranteed.
  final String? redirectUrl;

  /// Datetime of this change.
  final DateTime time;

  /// [PointsChange] is expected to exists inside a <table class="dt">.
  ///
  /// In that table, each <tr> (except the table header) can be converted to an
  /// instance of [PointsChange] :
  ///
  /// <tr>
  ///   <td>
  ///     <a>operation</a>
  ///   </td>
  ///   <td>
  ///     attr1
  ///     <span class="xi1">signed_value1</span>
  ///     attr2
  ///     <span class="xi1">signed_value2</span>
  ///     attr3
  ///     <span class="xi1">signed_value3</span>
  ///     ...
  ///   </td>
  ///   <td>
  ///     <a href=link_to_the_thread>detail</a>
  ///   </td>
  ///   <td>datetime</td>
  ///
  /// This function tries to build [PointsChange] from <tr> [element].
  static PointsChange? fromTrNode(uh.Element element) {
    final tdList = element.querySelectorAll('td');
    if (tdList.length != 4) {
      debug('failed to build PointsChange instance: '
          'invalid td count: ${tdList.length}');
      return null;
    }

    final operation = tdList[0].querySelector('a')?.innerText;
    final operationFilterUrl = tdList[0].querySelector('a')?.attributes['href'];
    if (operation == null || operationFilterUrl == null) {
      debug('failed to build PointsChange: operation=$operation, '
          'operationFilterUrl=$operationFilterUrl');
      return null;
    }
    final attrNameList = <String>[];
    final attrValueList = <String>[];
    for (final node in tdList[1].childNodes) {
      if (node.nodeType == uh.Node.ELEMENT_NODE) {
        final e = node as uh.Element;
        if (e.localName == 'span') {
          attrValueList.add(e.innerText.trim());
        }
      } else if (node.nodeType == uh.Node.TEXT_NODE) {
        final attrNameText = node.text?.trim();
        if (attrNameText?.isNotEmpty ?? false) {
          attrNameList.add(attrNameText!);
        }
      }
    }
    if (attrNameList.length != attrValueList.length) {
      debug('failed to build PointsChange: invalid attar name '
          'value length: $attrNameList and $attrValueList');
      return null;
    }

    // Points become more or less on this change.
    final pointsChangeType =
        switch (tdList[1].querySelector('span')?.classes.firstOrNull) {
      // Up lifted changelog has an orange font color with class name "xi1"
      'xi1' => PointsChangeType.more,
      // Down lifted changelog has an gray font color with class name "xg1".
      'xg1' => PointsChangeType.less,
      // Fallback to unknown type.
      // This might not happen but we should consider it.
      String() || null => PointsChangeType.unknown,
    };
    final changeMap = <String, String>{};
    for (var i = 0; i < attrNameList.length; i++) {
      changeMap[attrNameList[i]] = attrValueList[i];
    }

    final detail = tdList[2].innerText.trim();
    final redirectUrl =
        tdList[2].querySelector('a')?.attributes['href']?.prependHost();
    final changedTime = tdList[3].innerText.trim().parseToDateTimeUtc8();
    if (changedTime == null) {
      debug('failed to build PointsChange: invalid change time:'
          '${tdList[3].innerText.trim()}');
      return null;
    }

    return PointsChange(
      operation: operation,
      operationFilterUrl: operationFilterUrl,
      pointsChangeType: pointsChangeType,
      detail: detail,
      redirectUrl: redirectUrl,
      changeMap: changeMap,
      time: changedTime,
    );
  }

  /// Get tht formatted change.
  String get changeMapString =>
      changeMap.entries.map((e) => '${e.key} ${e.value}').join(',');

  @override
  List<Object?> get props => [
        operation,
        operationFilterUrl,
        pointsChangeType,
        changeMap,
        detail,
        redirectUrl,
        time,
      ];
}
