import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
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
    final cache = getIt.get<ImageCacheProvider>().getCacheInfo(imageUrl);
    if (cache != null) {
      final fileCache =
          getIt.get<ImageCacheProvider>().getCacheFile(cache.fileName);
      if (fileCache.existsSync()) {
        final image = Image.file(
          fileCache,
          width: maxWidth,
          height: maxHeight,
          fit: fit,
        );
        if (tag != null) {
          return Hero(tag: tag!, child: image);
        } else {
          return image;
        }
      }
    }

    return FutureBuilder(
      future: getIt
          .get<ImageCacheProvider>()
          .getCache(imageUrl)
          .onError((e, st) async {
        // When error occurred in `getCache`, it means the image is not
        // correctly cached, fetch from network.
        final resp = await getIt.get<NetClientProvider>().getImage(
              imageUrl,
            );
        final imageData = resp.data as List<int>;

        // Make cache.
        await getIt.get<ImageCacheProvider>().updateCache(imageUrl, imageData);
        return Uint8List.fromList(imageData);
      }),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debug('failed to get cached image: ${snapshot.error}');
          return FallbackPicture(fit: fit);
        }
        if (snapshot.hasData) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? double.infinity,
              maxHeight: maxHeight ?? double.infinity,
            ),
            child: Image.memory(
              snapshot.data!,
              fit: fit,
              errorBuilder: (context, e, st) {
                debug('failed to load image from $imageUrl: $e');
                return FallbackPicture(fit: fit);
              },
            ),
          );
        }
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? double.infinity,
            maxHeight: maxHeight ?? double.infinity,
          ),
          child: Shimmer.fromColors(
            baseColor:
                Theme.of(context).colorScheme.surfaceTint.withOpacity(0.8),
            highlightColor:
                Theme.of(context).colorScheme.surfaceTint.withOpacity(0.6),
            child: FallbackPicture(fit: fit),
          ),
        );
      },
    );
  }
}
