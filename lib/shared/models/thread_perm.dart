part of 'models.dart';

/// Thread perm
@MappableClass()
final class ThreadPerm with ThreadPermMappable {
  /// Constructor.
  const ThreadPerm({
    required this.groupName,
    required this.perm,
    required this.selected,
  });

  /// Readable user group name.
  final String groupName;

  /// Perm value.
  final String perm;

  /// Perm option selected or not.
  ///
  /// Note that the selected state here is only the one delivered from server
  /// through http response document.
  ///
  /// Several perm options may be selected at the same time if they have the
  /// same [perm] value. The one to display is the last one's [groupName].
  final bool selected;

  /// Build a list of [ThreadPerm] from given html [element].
  ///
  /// [element] MUST be `select` node:
  ///
  /// ```html
  /// <select name="readperm">
  ///   <option value="">不限</option>
  ///   <option value="1">游客</option>
  ///   ...
  /// </select>
  /// ```
  static List<ThreadPerm> buildListFromSelect(uh.Element element) {
    return element
        .querySelectorAll('option')
        .where((e) => e.attributes.containsKey('value'))
        .map(
          (e) => ThreadPerm(
            groupName: e.innerHtmlEx(),
            perm: e.attributes['value']!,
            selected: e.attributes['selected'] == 'selected',
          ),
        )
        .toList();
  }
}
