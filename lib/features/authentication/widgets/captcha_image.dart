import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/providers.dart';
import 'package:tsdm_client/utils/logger.dart';

/// Captcha image size is 320x150.
const _captchaImageWidth = 320;
const _captchaImageHeight = 150;

/// Row height is 60 (Default).
/// So indicator should use (150 / 60) * 320 width.
const _indicatorBoxWidth = (60 / _captchaImageHeight) * _captchaImageWidth;

/// The captcha image used in login form.
class CaptchaImage extends StatefulWidget {
  /// Constructor.
  const CaptchaImage({super.key});

  static final Uri _fakeFormVerifyUri =
      Uri.https('tsdm39.com', '/plugin.php', {'id': 'oracle:verify'});

  @override
  State<CaptchaImage> createState() => _VerityImageState();
}

class _VerityImageState extends State<CaptchaImage> with LoggerMixin {
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
    f = getIt
        .get<NetClientProvider>(instanceName: ServiceKeys.noCookie)
        .getImageFromUri(
          CaptchaImage._fakeFormVerifyUri,
          // Uri.parse('https://source.unsplash.com/random/320x150'),
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
            ),
          );
        },
      ),
    );
  }
}
