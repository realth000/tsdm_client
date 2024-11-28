import 'dart:async';
import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/providers.dart';
import 'package:tsdm_client/utils/logger.dart';

const _contentTypeImageAvif = 'image/avif';

// Future<ui.ImmutableBuffer> _loadNoAvatarBytes() async {
//  return rootBundle.loadBuffer(assetNoAvatarImagePath);
// }

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
    this.usage = const ImageUsageInfoOther(),
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

  /// Usage of the image.
  final ImageUsageInfo usage;

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
    var bytes = Uint8List(0);
    try {
      assert(key == this, 'check instance in load async');

      final f = switch (usage) {
        ImageUsageInfoOther() =>
          getIt.get<ImageCacheProvider>().getCache(imageUrl),
        ImageUsageInfoUserAvatar(:final username) =>
          getIt.get<ImageCacheProvider>().getUserAvatarCache(username),
      };

      bytes = await f.onError((e, st) async {
        if (!context.mounted || imageUrl.isEmpty) {
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
            handleRaw(e ?? '<no exception>', st);
            return Uint8List(0);
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
        final Uint8List imageData;

        if (resp.headers.map[Headers.contentTypeHeader]?.firstOrNull ==
            _contentTypeImageAvif) {
          // Avif format is not supported by dart image, parse and convert to
          // normal png ones, so image data is saved in png format that dart
          // image support.
          //
          // Currently only the very first frame is reserved, all other frames
          // are discard during conversion.
          final avifFrames = await decodeAvif(resp.data as Uint8List);
          if (avifFrames.isEmpty) {
            imageData = Uint8List(0);
            warning('image from url is in avif format has no frame, url: $url');
          } else {
            if (avifFrames.length != 1) {
              warning('image from url is in avif format has multiple frames, '
                  'only reserve the first frame and discarding other frames: '
                  'url: $url');
            }
            final byteData = await avifFrames.first.image
                .toByteData(format: ui.ImageByteFormat.png);
            if (byteData == null) {
              warning('image from url is in avif format has one invalid frame '
                  'url: $url');
              imageData = Uint8List(0);
            } else {
              imageData = byteData.buffer.asUint8List();
            }
          }
        } else {
          imageData = resp.data as Uint8List;
        }

        // Make cache.
        await getIt.get<ImageCacheProvider>().updateCache(
              imageUrl,
              imageData,
              usage: usage,
            );
        return Uint8List.fromList(imageData);
      });

      if (bytes.lengthInBytes == 0) {
        throw Exception('zero bytes');
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
      return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
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
  int get hashCode => Object.hash(url, scale, usage, context);

  @override
  String toString() => '${objectRuntimeType(this, 'CachedImageProvider')}'
      '("$url", scale: $scale, usage: $usage)';
}
