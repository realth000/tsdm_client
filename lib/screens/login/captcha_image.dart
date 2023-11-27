import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';

/// Captcha image size is 320x150.
const _captchaImageWidth = 320;
const _captchaImageHeight = 150;

/// Row height is 60 (Default).
/// So indicator should use (150 / 60) * 320 width.
const _indicatorBoxWidth = (60 / _captchaImageHeight) * _captchaImageWidth;

class CaptchaImage extends ConsumerStatefulWidget {
  const CaptchaImage({super.key});

  static final Uri _fakeFormVerifyUri =
      Uri.https('tsdm39.com', '/plugin.php', {'id': 'oracle:verify'});

  @override
  ConsumerState<CaptchaImage> createState() => _VerityImageState();
}

class _VerityImageState extends ConsumerState<CaptchaImage> {
  /// Debounce refreshing.
  bool refreshDebounce = false;

  /// Need this variable to mark whether the future [f] is completed or not.
  /// Because when refreshing state triggered by user interaction, it's weired
  /// that the [FutureBuilder] below has the previous data and does not show
  /// [CircularProgressIndicator] as planned.
  bool futureComplete = false;
  late Future<Response<dynamic>> f;

  @override
  Widget build(BuildContext context) {
    debug('fetching login captcha');
    f = ref
        .read(netClientProvider())
        .getUri(
          CaptchaImage._fakeFormVerifyUri,
          // Uri.parse('https://source.unsplash.com/random/320x150'),
          options: Options(responseType: ResponseType.bytes),
        )
        .whenComplete(() {
      futureComplete = true;
    });
    return GestureDetector(
      onTap: () async {
        if (refreshDebounce) {
          return;
        }
        setState(() {
          refreshDebounce = true;
          futureComplete = false;
        });
        debug('refresh login captcha');
        await Future.delayed(const Duration(milliseconds: 4000), () {
          refreshDebounce = false;
        });
      },
      child: FutureBuilder(
        future: f,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final message =
                t.loginPage.failedToGetCaptcha(err: snapshot.error!);
            debug(message);
            return Text(message);
          }

          if (snapshot.hasData && futureComplete) {
            final bytes = Uint8List.fromList(snapshot.data!.data as List<int>);
            debug('fetch login captcha finished, ${f.hashCode}');
            return Image.memory(bytes, height: 60);
          }
          return const SizedBox(
              width: _indicatorBoxWidth,
              child: Center(
                child: CircularProgressIndicator(),
              ));
        },
      ),
    );
  }
}
