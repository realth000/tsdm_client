import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/utils/clipboard.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';

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
            onPressed:
                () async => showDialog(
                  context: context,
                  builder:
                      (_) => RootPage(
                        DialogPaths.imageDetail,
                        SimpleDialog(
                          title: Text(tr.statistics),
                          contentPadding: edgeInsetsL24T24R24B24,
                          children: [
                            FutureBuilder(
                              future: getIt.get<ImageCacheProvider>().getEnsureCachedFullInfo(imageUrl),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(child: Text(tr.failedToLoadWithReason(reason: '${snapshot.error}')));
                                }

                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                final data = snapshot.data;

                                if (data == null) {
                                  return Center(child: Text(tr.failedToLoad));
                                }

                                return Column(
                                  spacing: 8,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      spacing: 8,
                                      children: [
                                        Expanded(child: Text(tr.url(url: data.url))),
                                        IconButton(
                                          icon: const Icon(Icons.copy_outlined),
                                          onPressed: () async => copyToClipboard(context, data.url),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 8,
                                      children: [
                                        Expanded(child: Text(tr.cacheName(name: data.fileName))),
                                        IconButton(
                                          icon: const Icon(Icons.copy_outlined),
                                          onPressed: () async => copyToClipboard(context, data.fileName),
                                        ),
                                      ],
                                    ),
                                    Text(tr.size(width: data.width, height: data.height)),
                                    Text(tr.cacheSize(size: data.cacheSize)),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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
          loadingBuilder: (_, _) => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
