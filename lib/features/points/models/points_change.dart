import 'package:equatable/equatable.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

/// A single change on the user's points.
///
/// Contains of change operation, attr points change list, change detail and
/// happened datetime.
class PointsChange extends Equatable {
  /// Constructor
  const PointsChange({
    required this.operation,
    required this.changeMap,
    required this.detail,
    required this.time,
    this.redirectUrl,
  });

  /// Operation type of this change.
  final String operation;

  /// Map of the changes in different attr types with their names and values.
  final Map<String, String> changeMap;

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
    if (operation == null) {
      debug('failed to build PointsChange: operation not found');
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
    final changeMap = <String, String>{};
    for (var i = 0; i < attrNameList.length; i++) {
      changeMap[attrNameList[i]] = attrValueList[i];
    }

    final detail = tdList[2].innerText;
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
        changeMap,
        detail,
        redirectUrl,
        time,
      ];
}
