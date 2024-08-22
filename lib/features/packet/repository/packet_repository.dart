import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// 红包
final class PacketRepository {
  /// Receive a packet from [url].
  AsyncEither<uh.Document> receivePacket(String url) => AsyncEither(() async {
        final resp = await getIt.get<NetClientProvider>().get(url);
        if (resp.statusCode != HttpStatus.ok) {
          return left(HttpRequestFailedException(resp.statusCode));
        }
        final document = parseHtmlDocument(resp.data as String);
        return right(document);
      });
}
