import 'package:tsdm_client/shared/models/models.dart';

/// The general info describing a cached image.
///
/// This class includes all fields in image cache table which is called `ImageEntity`, also image technical info
/// including image size.
final class ImageCacheInfo {
  /// Constructor.
  const ImageCacheInfo({
    required this.url,
    required this.fileName,
    required this.lastCachedTime,
    required this.lastUsedTime,
    required this.usage,
    required this.width,
    required this.height,
    required this.cacheSize,
  });

  /// Image url.
  final String url;

  /// Cache file name.
  final String fileName;

  /// Last updated and cached time.
  final DateTime lastCachedTime;

  /// Last visited and used time.
  final DateTime lastUsedTime;

  /// Usage of the image.
  final ImageUsage? usage;

  /// Pixel width.
  final int width;

  /// Pixel height.
  final int height;

  /// Size of image cache file, with size suffix: 'B', 'KB', ... .
  final String cacheSize;
}
