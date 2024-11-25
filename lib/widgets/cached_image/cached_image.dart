import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';
import 'package:tsdm_client/widgets/fallback_picture.dart';

/// Image that supports caching.
///
/// * First try to read from cache.
/// * If no cache available, fetch image from [imageUrl].
class CachedImage extends StatelessWidget with LoggerMixin {
  /// Constructor.
  const CachedImage(
    this.imageUrl, {
    this.width,
    this.height,
    this.maxWidth,
    this.maxHeight,
    this.minWidth,
    this.minHeight,
    this.fit,
    this.tag,
    this.enableAnimation = true,
    super.key,
  });

  /// Image to fetch url.
  ///
  /// Also the key to find cached image data.
  final String imageUrl;

  /// Fixed image width.
  final double? width;

  /// Fixed image height.
  final double? height;

  /// Max image width.
  final double? maxWidth;

  /// Max image height.
  final double? maxHeight;

  /// Min image width.
  final double? minWidth;

  /// Min image height.
  final double? minHeight;

  /// Fit type.
  final BoxFit? fit;

  /// Tag for hero animation.
  final String? tag;

  /// Enable animation between image loading states.
  ///
  /// Default is true.
  final bool enableAnimation;

  Widget _buildPlaceholder(BuildContext context) => Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        child: FallbackPicture(fit: fit),
      );

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (imageUrl.isEmpty) {
      body = FallbackPicture(fit: fit);
    } else {
      body = Image(
        image: CachedImageProvider(imageUrl, context),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, e, st) {
          handleRaw(e, st);
          return FallbackPicture(fit: fit);
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          if (!enableAnimation) {
            return frame != null ? child : _buildPlaceholder(context);
          }
          return AnimatedSwitcher(
            duration: duration100,
            // Use layoutBuilder to let child image "maximized".
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            // Return the same placeholder until built finished to avoid size
            // change.
            child: frame != null ? child : _buildPlaceholder(context),
          );
        },
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
        minWidth: minWidth ?? 0,
        minHeight: minHeight ?? 0,
      ),
      child: body,
    );
  }
}
