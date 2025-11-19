import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/instance.dart';
import 'package:universal_html/html.dart' as uh;

part 'secondary_title.mapper.dart';

/// An available secondary title.
///
/// Some fields in the original page are ignore:
///
/// * Title description.
/// * Expiration.
@MappableClass()
final class SecondaryTitle with SecondaryTitleMappable {
  /// Constructor.
  const SecondaryTitle({required this.id, required this.name, required this.imageUrl, required this.activated});

  /// Parse the secondary title info in tr node.
  /// <tr>
  ///   <td>${ID}</td>
  ///   <td>${NAME}</td>
  ///   <td></td>
  ///   <td><img src=${IMAGE_URL}></td>
  ///   <td>${EXPIRATION}</td>
  ///   <td><a href="url_to_activate">activate_the_title</a></td>
  /// </tr>
  static SecondaryTitle? fromTr(uh.Element element) {
    final tds = element.querySelectorAll('td');
    if (tds.length != 6) {
      talker.error('failed to build secondary title: invalid td count: ${tds.length}');
      return null;
    }

    final id = tds.first.innerText.trim().parseToInt();
    final name = tds[1].innerText.trim();
    final imageUrl = tds[3].querySelector('img')?.imageUrl();
    if (id == null || name.isEmpty || imageUrl == null) {
      talker.error('invalid secondary title data: id=$id, name=$name, imageUrl=$imageUrl');
      return null;
    }

    return SecondaryTitle(id: id, name: name, imageUrl: imageUrl, activated: false);
  }

  /// Title id.
  final int id;

  /// Title name.
  final String name;

  /// Title image url.
  final String imageUrl;

  /// Using current secondary title or not.
  final bool activated;
}
