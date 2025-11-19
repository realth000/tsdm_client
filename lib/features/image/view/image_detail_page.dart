import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';
import 'package:tsdm_client/widgets/copy_content_dialog.dart';
import 'package:tsdm_client/widgets/indicator.dart';

/// Page to show a detail image.
final class ImageDetailPage extends StatelessWidget {
  /// Constructor.
  const ImageDetailPage(this.imageUrl, {super.key});

  /// Url to load the image.
  ///
  /// Usually this image is loaded from global cache.
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final tr = context.t.imageDetailPage;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: tr.statistics,
            onPressed: () async => showCopyContentDialogFutureBuilder(
              context: context,
              // Calling `then` is better than nested callback.
              // ignore: prefer_async_await
              contentFuture: getIt.get<ImageCacheProvider>().getEnsureCachedFullInfo(imageUrl).then((imageInfo) {
                if (imageInfo == null) {
                  return const [];
                }
                return <CopyableContent>[
                  CopyableContent(name: tr.url, data: imageInfo.url),
                  CopyableContent(name: tr.cacheName, data: imageInfo.fileName),
                  CopyableContent(name: tr.cacheSize, data: imageInfo.cacheSize),
                  CopyableContent(
                    name: tr.sizeTitle,
                    data: tr.sizeValue(width: imageInfo.width, height: imageInfo.height),
                  ),
                ];
              }),
              errorBuilder: (_, err) => Center(child: Text(tr.failedToLoadWithReason(reason: '$err'))),
              title: tr.statistics,
              route: DialogPaths.imageDetail,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: PhotoView(
          imageProvider: CachedImageProvider(imageUrl),
          maxScale: 3.0,
          minScale: 0.3,
          initialScale: PhotoViewComputedScale.contained,
          backgroundDecoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLowest),
          loadingBuilder: (_, _) => const CenteredCircularIndicator(),
        ),
      ),
    );
  }
}
