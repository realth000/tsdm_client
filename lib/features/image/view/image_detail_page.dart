import 'package:flutter/material.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/network_indicator_image.dart';
import 'package:widget_zoom/widget_zoom.dart';

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
      appBar: AppBar(title: Text(tr.title)),
      body: SafeArea(child: WidgetZoom(heroAnimationTag: 'imageUrl', zoomWidget: NetworkIndicatorImage(imageUrl))),
    );
  }
}
