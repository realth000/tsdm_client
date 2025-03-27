import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:universal_html/html.dart' as uh;

part 'checkin.mapper.dart';

/// Checkin status of current post floor.
@MappableClass()
final class PostCheckinStatus with PostCheckinStatusMappable {
  /// Constructor.
  const PostCheckinStatus({
    required this.feelingImage,
    required this.feelingName,
    required this.words,
    required this.statistics,
  });

  /// Url of image on feeling.
  final String feelingImage;

  /// Readable name of feeling.
  final String feelingName;

  /// Some words to say.
  final String words;

  /// Checkin status.
  final String statistics;

  /// Build instance from checkin `<div>` node.
  static PostCheckinStatus? fromDiv(uh.Element element) {
    final feelingImage = element.querySelector('li > table > tbody > tr > th:nth-child(1) > a > img')?.imageUrl();
    final feelingName = element.querySelector('li > table > tbody > tr > th:nth-child(2)')?.firstEndDeepText();
    final words = element.querySelector('li > div')?.firstEndDeepText();
    final statistics = element.querySelector('li > p')?.firstEndDeepText();

    if (feelingImage == null || feelingName == null || words == null || statistics == null) {
      return null;
    }

    return PostCheckinStatus(
      feelingImage: feelingImage,
      feelingName: feelingName,
      words: words,
      statistics: statistics,
    );
  }
}
