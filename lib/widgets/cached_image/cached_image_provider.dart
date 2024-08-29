import 'dart:async';
import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/providers.dart';
import 'package:tsdm_client/utils/logger.dart';

/// A provider that provides cached image.
///
/// Refer:
/// * https://github.com/Baseflow/flutter_cached_network_image/blob/develop/cached_network_image/lib/src/image_provider/cached_network_image_provider.dart
/// * ${flutter_sdk}/lib/src/painting/_network_image_io.dart
@immutable
final class CachedImageProvider extends ImageProvider<CachedImageProvider>
    with LoggerMixin {
  /// Constructor.
  const CachedImageProvider(
    this.imageUrl,
    this.context, {
    this.scale = 1.0,
    this.maxWidth,
    this.maxHeight,
    this.fallbackImageUrl,
  });

  /// Url of image.
  final String imageUrl;

  /// Use check widget mounted.
  ///
  /// Workaround to fix "ref used after widget dispose" exception.
  final BuildContext context;

  /// Max image width.
  final double? maxWidth;

  /// Max image height.
  final double? maxHeight;

  /// Image scale factor.
  final double scale;

  /// Use this image if [imageUrl] is unavailable.
  final String? fallbackImageUrl;

  /// Get the image url.
  String get url => imageUrl;

  @override
  Future<CachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    CachedImageProvider key,
    ImageDecoderCallback decode,
  ) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode: decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<CachedImageProvider>('Image key', key),
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

      final bytes = await getIt
          .get<ImageCacheProvider>()
          .getCache(imageUrl)
          .onError((e, st) async {
        if (!context.mounted) {
          return Uint8List(0);
        }
        // When error occurred in `getCache`, it means the image is not
        // correctly cached, fetch from network.
        final respEither = await getIt
            .get<NetClientProvider>(instanceName: ServiceKeys.noCookie)
            .getImage(imageUrl)
            .run();
        if (respEither.isLeft()) {
          // Error occurred when fetching this image.
          // If we have [fallbackImageUrl], use it.
          if (fallbackImageUrl == null) {
            // Rethrow if can not fallback.
          }
          final cacheRet = await getIt
              .get<NetClientProvider>(instanceName: ServiceKeys.noCookie)
              .getImage(fallbackImageUrl!)
              .run();
          if (cacheRet.isLeft()) {
            handle(cacheRet.unwrapErr());
            return Uint8List(0);
          }
          handle(respEither.unwrapErr());
          return Uint8List(0);
        }

        if (!context.mounted) {
          return Uint8List(0);
        }
        final resp = respEither.unwrap();
        if (resp.statusCode != HttpStatus.ok) {
          error('failed to get image from $imageUrl, code=${resp.statusCode}');
          return Uint8List(0);
        }
        final imageData = resp.data as Uint8List;

        // Make cache.
        await getIt.get<ImageCacheProvider>().updateCache(imageUrl, imageData);
        return Uint8List.fromList(imageData);
      });

      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkImage is an empty file: $imageUrl');
      }
      return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (e) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      await chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CachedImageProvider &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'CachedImageProvider')}'
      '("$url", scale: $scale)';
}
