import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tsdm_client/features/cache/bloc/image_cache_bloc.dart';
import 'package:tsdm_client/features/cache/models/models.dart';
import 'package:tsdm_client/features/cache/repository/image_cache_repository.dart';
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

  Widget _buildImage(BuildContext context, Uint8List imageData) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: Image.memory(
        imageData,
        fit: fit,
        errorBuilder: (context, e, st) {
          debug('failed to load image from $imageUrl: $e');
          return FallbackPicture(fit: fit);
        },
      ),
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

    // final cache = getIt.get<ImageCacheProvider>().getCacheInfo(imageUrl);
    // if (cache != null) {
    //   final fileCache =
    //       getIt.get<ImageCacheProvider>().getCacheFile(cache.fileName);
    //   if (fileCache.existsSync()) {
    //     final image = Image.file(
    //       fileCache,
    //       width: maxWidth,
    //       height: maxHeight,
    //       fit: fit,
    //     );
    //     if (tag != null) {
    //       return Hero(tag: tag!, child: image);
    //     } else {
    //       return image;
    //     }
    //   }
    // }

    final loadingPlaceholder = ConstrainedBox(
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

    return BlocProvider(
      create: (context) =>
          ImageCacheBloc(imageUrl, RepositoryProvider.of(context))
            ..add(const ImageCacheLoadRequested()),
      child: BlocBuilder<ImageCacheBloc, ImageCacheState>(
        builder: (context, state) {
          return StreamBuilder(
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
