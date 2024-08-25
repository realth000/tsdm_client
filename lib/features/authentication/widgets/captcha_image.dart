import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/providers.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/widgets/fallback_picture.dart';

/// Captcha image size is 320x150.
const _captchaImageWidth = 320.0;
const _captchaImageHeight = 150.0;

const _renderHeight = 52.0;

const _indicatorBoxWidth =
    (_renderHeight / _captchaImageHeight) * _captchaImageWidth;

/// The captcha image used in login form.
class CaptchaImage extends StatefulWidget {
  /// Constructor.
  const CaptchaImage(this.controller, {super.key});

  static final Uri _fakeFormVerifyUri =
      Uri.https('tsdm39.com', '/plugin.php', {'id': 'oracle:verify'});

  /// Injected controller.
  final CaptchaImageController controller;

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
  Future<SyncEither<Response<dynamic>>>? f;

  Future<void> reload() async {
    if (refreshDebounce) {
      return;
    }
    debug('fetching login captcha');
    f = getIt
        .get<NetClientProvider>(instanceName: ServiceKeys.noCookie)
        .getImageFromUri(CaptchaImage._fakeFormVerifyUri)
        .run()
        .whenComplete(() {
      futureComplete = true;
    });

    setState(() {
      refreshDebounce = true;
      futureComplete = false;
    });
    debug('refresh login captcha');
    await Future.delayed(const Duration(milliseconds: 4000), () {
      refreshDebounce = false;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller._bind(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await reload();
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller._unbind();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => reload(),
      child: FutureBuilder(
        future: f,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Impossible.
            final message =
                t.loginPage.failedToGetCaptcha(err: snapshot.error!);
            debug(message);
            return Text(message);
          }

          if (snapshot.hasData && futureComplete) {
            final either = snapshot.data!;
            if (either.isLeft()) {
              handle(either.unwrapErr());
              return const FallbackPicture();
            }

            final bytes =
                Uint8List.fromList(snapshot.data!.unwrap().data as List<int>);
            debug('fetch login captcha finished, ${f.hashCode}');
            // 130 x 60 -> 110.9 -> 52
            return Image.memory(bytes, height: _renderHeight);
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

/// Controller of [CaptchaImage].
final class CaptchaImageController {
  /// Shared state, not own it.
  _VerityImageState? _state;

  void _bind(_VerityImageState s) {
    _state = s;
    reload();
  }

  void _unbind() {
    _state = null;
  }

  /// Reload captcha image.
  void reload() {
    _state?.reload();
  }

  /// Release resource.
  void dispose() {
    _state = null;
  }
}
