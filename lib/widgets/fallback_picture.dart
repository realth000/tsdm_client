import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/constants.dart';

/// Default picture.
///
/// Use it when fetch picture failed or loading picture as a placeholder.
class FallbackPicture extends StatelessWidget {
  /// Constructor.
  const FallbackPicture({this.fit, this.width, this.height, super.key});

  /// Fit type.
  final BoxFit? fit;

  /// Optional image width.
  final double? width;

  /// Optional image height.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetsLogoPngPath,
      color: Theme.of(context).colorScheme.outlineVariant,
      fit: fit,
      width: width,
      height: height,
    );
  }
}
