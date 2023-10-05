import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';

class CaptchaImage extends ConsumerStatefulWidget {
  const CaptchaImage({super.key});

  static final Uri _fakeFormVerifyUri =
      Uri.https('tsdm39.com', '/plugin.php', {'id': 'oracle:verify'});

  @override
  ConsumerState<CaptchaImage> createState() => _VerityImageState();
}

class _VerityImageState extends ConsumerState<CaptchaImage> {
  @override
  Widget build(BuildContext context) {
    debug('fetching login captcha');
    return FutureBuilder(
      future: ref.read(netClientProvider).getUri(
            CaptchaImage._fakeFormVerifyUri,
            options: Options(responseType: ResponseType.bytes),
          ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final message = 'failed to get login captcha: ${snapshot.error}';
          debug(message);
          return Text(message);
        }

        if (snapshot.hasData) {
          final bytes = Uint8List.fromList(snapshot.data!.data as List<int>);
          return Image.memory(bytes);
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
