import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/instance.dart';
import 'package:universal_html/html.dart' as uh;

part 'post_medal.mapper.dart';

/// Each instance of [PostMedal] is a medal in the post floor in thread.
///
/// Medals in thread has a slightly different data structure from the ones in user profile page because part of the
/// medals' information is gathered in a top level invisible menu in the thread page.
/// So it comes with a different profile page medal fields: has extra id to specify the info in that hidden menu.
@MappableClass()
final class PostMedal with PostMedalMappable {
  /// Constructor.
  const PostMedal({required this.id, required this.image, required this.alter, required this.menuItemId});

  /// Medal id.
  ///
  /// The id field in medal html node.
  final String id;

  /// Image url.
  ///
  /// The image url is already prepend with host.
  final String image;

  /// Alter text in node.
  final String alter;

  /// Id in the hidden menu.
  ///
  /// This field locates the unique medal description in hidden menu.
  final String menuItemId;

  /// Build an instance from `<img>` node.
  static PostMedal? fromImg(uh.Element element) {
    // Use the `attributes` method here so the `id` is nullable.
    final id = element.attributes['id'];
    final image = element.attributes['src'];
    final alter = element.attributes['alt'];
    // onmouseover="showMenu({'ctrlid':this.id, 'menuid':'${MENU_ITEM_ID}', 'pos':'12!'});"
    final menuItemId = element.attributes['onmouseover']?.split("'").elementAtOrNull(5);

    if (id == null || image == null || alter == null || menuItemId == null) {
      talker.info('incomplete post medal info: id=$id, image=$image, alter=$alter, menuItemId=$menuItemId');
      return null;
    }

    return PostMedal(id: id, image: image, alter: alter, menuItemId: menuItemId);
  }
}
