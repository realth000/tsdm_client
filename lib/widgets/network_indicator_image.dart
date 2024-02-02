import 'package:flutter/material.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image.dart';

/// Network image with loading indicator.
class NetworkIndicatorImage extends StatelessWidget {
  /// Constructor.
  const NetworkIndicatorImage(this.src,
      {this.maxWidth, this.maxHeight, super.key,});

  /// Image network source url.
  final String src;

  final double? maxWidth;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) => CachedImage(
        src,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
}
