import 'package:equatable/equatable.dart';

/// A pair of url used in swiper in homepage.
final class SwiperUrl extends Equatable {
  /// Constructor.
  const SwiperUrl({required this.coverUrl, required this.linkUrl});

  /// Url of the Cover image.
  final String coverUrl;

  /// Url of the related link, will be opened when user clicked the cover image.
  final String linkUrl;

  @override
  List<Object> get props => [coverUrl, linkUrl];
}
