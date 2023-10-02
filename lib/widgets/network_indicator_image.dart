import 'package:flutter/material.dart';
import 'package:tsdm_client/utils/debug.dart';

/// Network image with loading indicator.
class NetworkIndicatorImage extends StatelessWidget {
  /// Constructor.
  const NetworkIndicatorImage(this.src, {super.key});

  /// Image network source url.
  final String src;

  @override
  Widget build(BuildContext context) => Image.network(
        src,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, _) {
          debug('error: $error');
          return const SizedBox(
            height: 50,
            width: 50,
            child: Icon(Icons.account_circle),
          );
        },
      );
}
