import 'package:dart_mappable/dart_mappable.dart';
import 'package:universal_html/html.dart' as uh;

part 'post_medal_menu_info.mapper.dart';

/// Info about medal in post, lives at the end of DOM.
@MappableClass()
final class PostMedalMenuItem with PostMedalMenuItemMappable {
  /// Constructor.
  const PostMedalMenuItem({required this.id, required this.name, required this.description});

  /// Unique id in dom.
  final String id;

  /// Medal name.
  final String name;

  /// Medal description.
  final String description;

  /// Build an instance from `<div>` node.
  ///
  /// ```html
  /// <div id="md_4_menu" class="tip tip_4" style="display: none;">
  ///     <div class="tip_horn"></div>
  ///     <div class="tip_c">
  ///         <h4>${NAME}</h4>
  ///         <p>${DESCRIPTION}</p>
  ///     </div>
  /// </div>
  /// ```
  static PostMedalMenuItem? fromDiv(uh.Element element) {
    // Use the `attribute` method so that `id` is nullable.
    final id = element.attributes['id'];
    final name = element.querySelector('div.tip_c > h4')?.innerText.trim();
    final description = element.querySelector('div.tip_c > p')?.innerText.trim();

    if (id == null || name == null || description == null) {
      return null;
    }

    return PostMedalMenuItem(id: id, name: name, description: description);
  }
}
