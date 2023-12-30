import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/constants.dart';

class FallbackPicture extends StatelessWidget {
  const FallbackPicture({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetsLogoPath,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
