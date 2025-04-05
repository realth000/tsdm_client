import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/instance.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

part 'profile_medal.mapper.dart';

/// Medal info in profile page.
@MappableClass()
final class ProfileMedal with ProfileMedalMappable {
  /// Constructor.
  const ProfileMedal({required this.name, required this.image, required this.alter, required this.description});

  /// Medal name.
  final String name;

  /// Image url.
  final String image;

  /// Alter text.
  final String alter;

  /// Medal description.
  final String description;

  /// Build instance from `<img>` node.
  ///
  /// ```html
  /// <img src=$IMAGE alt=$ALTER onmouseover="showTip(this)" tip="<h4>$NAME</h4><p>$DESCRIPTION</p>" />
  /// ```
  static ProfileMedal? fromImg(uh.Element element) {
    final image = element.imageUrl();
    final alter = element.attributes['alt'];
    final tip = element.attributes['tip'];
    if (image == null || alter == null || tip == null) {
      talker.warning('failed to build profile medal: image=$image, alter=$alter, tip=$tip');
      return null;
    }

    // Tip is expected to be `<h4>论坛贡献荣誉II</h4><p>论坛贡献荣誉II</p>` format.
    final tipDoc = parseHtmlDocument(tip);
    final name = tipDoc.querySelector('h4')?.innerText.trim();
    final description = tipDoc.querySelector('p')?.innerText.trim();

    if (name == null || description == null) {
      talker.warning('failed to build profile medal: name=$name, description=$description');
      return null;
    }

    return ProfileMedal(name: name, image: image, alter: alter, description: description);
  }
}
