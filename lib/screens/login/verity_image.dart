import 'package:dio_image_provider/dio_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';

class VerifyImage extends ConsumerStatefulWidget {
  const VerifyImage({super.key});

  static final Uri _fakeFormVerifyUri =
      Uri.https('tsdm39.com', '/plugin.php', {'id': 'oracle:verify'});

  @override
  ConsumerState<VerifyImage> createState() => _VerityImageState();
}

class _VerityImageState extends ConsumerState<VerifyImage> {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: DioImage(
        VerifyImage._fakeFormVerifyUri,
        dio: ref.read(netClientProvider),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
