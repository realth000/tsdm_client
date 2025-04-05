import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/instance.dart';
import 'package:universal_html/html.dart' as uh;

part 'managed_forum.mapper.dart';

/// Describe info on managed forum in user profile page.
@MappableClass()
final class ManagedForum with ManagedForumMappable {
  /// Constructor.
  const ManagedForum({required this.name, required this.fid});

  /// Name of forum.
  final String name;

  /// Id of forum.
  final int fid;

  /// Build from a node.
  ///
  /// ```html
  /// <a href="forum.php?mod=forumdisplay&amp;fid=$FID" target="_blank">$NAME</a>
  /// ```
  static ManagedForum? fromA(uh.Element element) {
    final name = element.innerText.trim();
    final fid = element.attributes['href']?.split('fid=').elementAtOrNull(1)?.parseToInt();

    if (fid == null) {
      talker.warning('failed to build managed forum: fid is null');
      return null;
    }

    return ManagedForum(name: name, fid: fid);
  }
}
