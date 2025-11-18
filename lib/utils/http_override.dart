import 'dart:io';

import 'package:tsdm_client/constants/url.dart';

/// Override SSL handshake settings.
final class AppHttpOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // Bypass these certificate checks increase security vulnerability but it's identified that the root certificate
    // used by image server (on 2025.11.19) is not available on multiple platforms and devices because of the let's
    // encrypt r12 certificate. We could add r12.pem in assets while nothing is promised days or months later.
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) {
        if (['tu.ts-dm.net', 'img.ts-dm.net', baseHost, baseHostAlt].contains(host)) {
          return true;
        } else {
          return false;
        }
      };
  }
}
