import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/image_cache_provider.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';

class CachedImage extends ConsumerWidget {
  const CachedImage(this.imageUrl, {this.maxWidth, this.maxHeight, super.key});

  final String imageUrl;
  final double? maxWidth;
  final double? maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref
          .read(imageCacheProvider.notifier)
          .getCache(imageUrl)
          .onError((e, st) async {
        // When error occurred in `getCache`, it means the image is not
        // correctly cached, fetch from network.
        final resp = await ref.read(netClientProvider()).get(
              imageUrl,
              options: Options(
                responseType: ResponseType.bytes,
                headers: {'Accept': 'image/avif,image/webp,*/*'},
              ),
            );
        final imageData = resp.data as List<int>;

        // Make cache.
        await ref
            .read(imageCacheProvider.notifier)
            .updateCache(imageUrl, imageData);
        return Uint8List.fromList(imageData);
      }),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debug('failed to get cached image: ${snapshot.error}');
          return const Placeholder();
        }
        if (snapshot.hasData) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? double.infinity,
              maxHeight: maxHeight ?? double.infinity,
            ),
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
            ),
          );
        }
        return Container();
      },
    );
  }
}
