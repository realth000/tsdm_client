import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/constants.dart';

/// Default picture.
///
/// Use it when fetch picture failed or loading picture as a placeholder.
class FallbackPicture extends StatelessWidget {
  /// Constructor.
  const FallbackPicture({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetsLogoPath,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
