import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/cache/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';
import 'package:tsdm_client/widgets/fallback_picture.dart';

/// Image that supports caching.
///
/// * First try to read from cache.
/// * If no cache available, fetch image from [imageUrl].
class CachedImage extends StatefulWidget {
  /// Constructor.
  CachedImage(
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
  }) : _imageProvider = CachedImageProvider(imageUrl);

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

  /// Image provider to render the content.
  late final CachedImageProvider _imageProvider;

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> with LoggerMixin {
  Widget _buildPlaceholder(BuildContext context) => Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        child: FallbackPicture(fit: widget.fit),
      );

  StreamSubscription<ImageCacheResponse>? imageSub;

  Future<void> onImageResponse(ImageCacheResponse resp) async {
    if (mounted && resp is ImageCacheLoadingResponse) {
      await widget._imageProvider.evict();
    }
  }

  @override
  void initState() {
    super.initState();
    imageSub = getIt
        .get<ImageCacheProvider>()
        .response
        .where(
          (e) =>
              e.respType == ImageCacheResponseType.general &&
              e.imageId == widget.imageUrl,
        )
        .listen((resp) async => onImageResponse(resp));
  }

  @override
  void dispose() {
    imageSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (widget.imageUrl.isEmpty) {
      body = FallbackPicture(fit: widget.fit);
    } else {
      body = Image(
        image: widget._imageProvider,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, e, st) {
          handleRaw(e, st);
          return FallbackPicture(fit: widget.fit);
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          if (!widget.enableAnimation) {
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
        maxWidth: widget.maxWidth ?? double.infinity,
        maxHeight: widget.maxHeight ?? double.infinity,
        minWidth: widget.minWidth ?? 0,
        minHeight: widget.minHeight ?? 0,
      ),
      child: body,
    );
  }
}
