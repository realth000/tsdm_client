import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';

// Future<ui.ImmutableBuffer> _loadNoAvatarBytes() async {
//  return rootBundle.loadBuffer(assetNoAvatarImagePath);
// }

/// A provider that provides cached image.
///
/// Refer:
/// * https://github.com/Baseflow/flutter_cached_network_image/blob/develop/cached_network_image/lib/src/image_provider/cached_network_image_provider.dart
/// * ${flutter_sdk}/lib/src/painting/_network_image_io.dart
@immutable
final class CachedImageProvider extends ImageProvider<CachedImageProvider> with LoggerMixin {
  /// Constructor.
  const CachedImageProvider(
    this.imageUrl, {
    this.scale = 1.0,
    this.maxWidth,
    this.maxHeight,
    this.fallbackImageUrl,
    this.usage = const ImageUsageInfoOther(),
  });

  /// Url of image.
  final String imageUrl;

  /// Max image width.
  final double? maxWidth;

  /// Max image height.
  final double? maxHeight;

  /// Image scale factor.
  final double scale;

  /// Use this image if [imageUrl] is unavailable.
  final String? fallbackImageUrl;

  /// Usage of the image.
  final ImageUsageInfo usage;

  /// Get the image url.
  String get url => imageUrl;

  Future<Option<Uint8List>> _onImageError() async {
    final req = switch (usage) {
      ImageUsageInfoOther() => ImageCacheGeneralRequest(imageUrl),
      ImageUsageInfoUserAvatar(:final username) => ImageCacheUserAvatarRequest(username: username, imageUrl: imageUrl),
    };

    return getIt.get<ImageCacheProvider>().getOrMakeCache(req);
  }

  @override
  Future<CachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(CachedImageProvider key, ImageDecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode: decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector:
          () => <DiagnosticsNode>[
            DiagnosticsProperty<ImageProvider>('CachedImageProvider', this),
            DiagnosticsProperty<CachedImageProvider>('ImageKey', key),
          ],
    );
  }

  Future<ui.Codec> _loadAsync(
    CachedImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents, {
    required ImageDecoderCallback decode,
  }) async {
    try {
      assert(key == this, 'check instance in load async');
      if (usage is! ImageUsageInfoUserAvatar && imageUrl.isEmpty) {
        // error('failed to make $usage: empty url');
        return ui.instantiateImageCodecFromBuffer(await getPlaceholderImageData());
      }
      final f = switch (usage) {
        ImageUsageInfoOther() => getIt.get<ImageCacheProvider>().getOrMakeCache(ImageCacheGeneralRequest(imageUrl)),
        ImageUsageInfoUserAvatar(:final username) => getIt.get<ImageCacheProvider>().getUserAvatarCache(
          username: username,
          imageUrl: imageUrl,
        ),
      };

      final bytes = (await f.onError((_, __) => _onImageError())).getOrElse(() => Uint8List(0));
      if (bytes.lengthInBytes == 0) {
        return ui.instantiateImageCodecFromBuffer(await getPlaceholderImageData());
      }
      return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (e) {
      // // Depending on where the exception was thrown, the image cache may not
      // // have had a chance to track the key in the cache at all.
      // // Schedule a microtask to give the cache a chance to add the key.
      // scheduleMicrotask(() {
      //   PaintingBinding.instance.imageCache.evict(key);
      // });
      // FIXME: Handle all exceptions.
      // error('CachedImageProvider caught error: $e');
      return Future.error('failed to render image: $e');
    } finally {
      await chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CachedImageProvider && other.imageUrl == imageUrl && other.usage == usage && other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(imageUrl, usage, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CachedImageProvider')}'
      '("$url", scale: $scale, usage: $usage)';
}
