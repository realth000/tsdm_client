part of 'models.dart';

/// A pair of url used in swiper in homepage.
@MappableClass()
final class SwiperUrl with SwiperUrlMappable {
  /// Constructor.
  const SwiperUrl({required this.coverUrl, required this.linkUrl});

  /// Url of the Cover image.
  final String coverUrl;

  /// Url of the related link, will be opened when user clicked the cover image.
  final String linkUrl;
}
