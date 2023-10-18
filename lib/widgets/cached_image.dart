import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/image_cache_provider.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';

class CachedImage extends ConsumerWidget {
  const CachedImage(this.imageUrl, {super.key});

  final String imageUrl;

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
              options: Options(responseType: ResponseType.bytes),
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
          return Image.memory(snapshot.data!);
        }
        return Container();
      },
    );
  }
}
