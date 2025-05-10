import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/uri.dart';
import 'package:tsdm_client/instance.dart';
import 'package:universal_html/html.dart' as uh;

/// User groups, for witch current user can switch to.
final class AvailableUserGroup {
  /// Constructor.
  const AvailableUserGroup({required this.name, required this.gid, required this.infoUrl});

  /// User group name.
  final String name;

  /// Group id.
  final int gid;

  /// Url of page introducing user group permissions.
  final String infoUrl;

  /// Build instance from `<tr>` node.
  ///
  /// Each `<tr>` node is a row in the available user group table.
  ///
  /// ```html
  /// <tr class="">
  /// <td><a href="$INFO_URL" class="xi2" target="_blank">$NAME</a></td>
  /// <td>
  /// </td>
  /// <td></td>
  /// <td></td>
  /// <td>
  /// <a href="URL_TO_SWITCH_GROUP" class="xw1 xi2" onclick="showWindow('group', this.href, 'get', 0);">切换</a>
  /// </td>
  /// </tr>
  /// ```
  static AvailableUserGroup? fromTr(uh.Element element) {
    final nameNode = element.querySelector('td:nth-child(1) > a');
    final name = nameNode?.innerText.trim();
    final infoUrl = nameNode?.attributes['href'];
    final gid = infoUrl?.tryParseAsUri()?.tryGetQueryParameters()?['gid']?.parseToInt();

    if (name == null || infoUrl == null || gid == null) {
      talker.error('failed to parse avaiable user group: name=$name, infoUrl=$infoUrl, gid=$gid');
      return null;
    }

    return AvailableUserGroup(name: name, infoUrl: infoUrl, gid: gid);
  }
}
