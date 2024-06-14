import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/cache/bloc/image_cache_bloc.dart';
import 'package:tsdm_client/features/cache/models/models.dart';
import 'package:tsdm_client/features/cache/repository/image_cache_repository.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/widgets/fallback_picture.dart';

/// Image that supports caching.
///
/// * First try to read from cache.
/// * If no cache available, fetch image from [imageUrl].
class CachedImage extends StatelessWidget {
  /// Constructor.
  const CachedImage(
    this.imageUrl, {
    this.maxWidth,
    this.maxHeight,
    this.fit,
    this.tag,
    this.enableAnimation = true,
    super.key,
  });

  /// Image to fetch url.
  ///
  /// Also the key to find cached image data.
  final String imageUrl;

  /// Max image width.
  final double? maxWidth;

  /// Max image height.
  final double? maxHeight;

  /// Fit type.
  final BoxFit? fit;

  /// Tag for hero animation.
  final String? tag;

  /// Enable animation between image loading states.
  ///
  /// Default is true.
  final bool enableAnimation;

  Widget _buildPlaceholder(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.surfaceTint.withOpacity(0.8),
          highlightColor:
              Theme.of(context).colorScheme.surfaceTint.withOpacity(0.6),
          child: FallbackPicture(fit: fit),
        ),
      );

  Widget _buildImage(BuildContext context, Uint8List imageData) {
    return Image.memory(
      imageData,
      fit: fit,
      errorBuilder: (context, e, st) {
        debug('failed to load image from $imageUrl: $e');
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
          duration: duration200,
          // Use layoutBuilder to let child image "maximized".
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null)
                  // TODO: Use convenient widget instead of layout builder.
                  LayoutBuilder(
                    builder: (context, cons) {
                      // Sometimes max height is infinity and the comparison
                      // may be costly.
                      // FIXME: Remove compare.
                      if (cons.maxHeight == double.infinity) {
                        return currentChild;
                      }
                      return SizedBox(
                        width: cons.maxWidth,
                        height: cons.maxHeight,
                        child: currentChild,
                      );
                    },
                  ),
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
    if (imageUrl.isEmpty) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: FallbackPicture(fit: fit),
      );
    }

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
    ImageCacheSuccessResponse? initialData;
    if (initialImageData != null) {
      initialData = ImageCacheSuccessResponse(
        imageUrl,
        initialImageData,
      );
    }

    final loadingPlaceholder = _buildPlaceholder(context);

    return BlocProvider(
      create: (context) {
        final bloc = ImageCacheBloc(imageUrl, RepositoryProvider.of(context));
        if (initialData == null) {
          bloc.add(const ImageCacheLoadRequested());
        }
        return bloc;
      },
      child: BlocBuilder<ImageCacheBloc, ImageCacheState>(
        builder: (context, state) {
          return StreamBuilder(
            initialData: initialData,
            stream: RepositoryProvider.of<ImageCacheRepository>(context)
                .response
                .where((e) => e.imageId == imageUrl),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return loadingPlaceholder;
              }

              final resp = snapshot.data!;

              final content = switch (resp) {
                ImageCacheLoadingResponse() => loadingPlaceholder,
                ImageCacheSuccessResponse(:final imageData) =>
                  _buildImage(context, imageData),
                ImageCacheFailedResponse() => () {
                    debug('failed to load image from $imageUrl');
                    return loadingPlaceholder;
                  }(),
                ImageCacheStatusResponse(:final status, :final imageData) =>
                  switch (status) {
                    ImageCacheStatus2.notCached ||
                    ImageCacheStatus2.loading =>
                      loadingPlaceholder,
                    ImageCacheStatus2.cached =>
                      _buildImage(context, imageData!),
                  }
              };

              return content;
            },
          );
        },
      ),
    );
  }
}
