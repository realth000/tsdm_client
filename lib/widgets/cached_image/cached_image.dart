import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/cache/bloc/image_cache_bloc.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
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

  Widget _buildImage({
    required BuildContext context,
    required Uint8List imageData,
  }) {
    return Image.memory(
      imageData,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, e, st) {
        error('failed to load image from $imageUrl: $e');
        return FallbackPicture(fit: fit);
      },
      // Use frameBuilder to reduce the widget splash when loading image.
      // ref: https://stackoverflow.com/a/71430971
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

  @override
  Widget build(BuildContext context) {
    final Widget body;

    if (imageUrl.isEmpty) {
      body = FallbackPicture(fit: fit);
    } else {
      Uint8List? initialImageData;
      final cache = getIt.get<ImageCacheProvider>().getCacheInfo(imageUrl);
      if (cache != null) {
        final fileCache =
            getIt.get<ImageCacheProvider>().getCacheFile(cache.fileName);
        if (fileCache.existsSync()) {
          initialImageData = fileCache.readAsBytesSync();
          // if (tag != null) {
          //   return Hero(tag: tag!, child: image);
          // } else {
          //   return image;
          // }
        }
      }

      body = BlocProvider(
        create: (context) {
          final ImageCacheBloc bloc;
          if (initialImageData == null) {
            bloc = ImageCacheBloc(imageUrl, context.repo())
              ..add(const ImageCacheLoadRequested());
          } else {
            bloc = ImageCacheBloc(
              imageUrl,
              context.repo(),
              initialImage: initialImageData,
            );
          }
          return bloc;
        },
        child: BlocBuilder<ImageCacheBloc, ImageCacheState>(
          builder: (context, state) {
            switch (state) {
              case ImageCacheInitial() || ImageCacheLoading():
                return _buildPlaceholder(context);
              case ImageCacheSuccess(:final imageData):
                return _buildImage(
                  context: context,
                  imageData: imageData,
                );
              case ImageCacheFailure():
                return FallbackPicture(fit: fit);
            }
          },
        ),
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
