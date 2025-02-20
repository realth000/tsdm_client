import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository to fetch chat related source.
final class ChatRepository {
  /// Constructor.
  const ChatRepository();

  /// Fetch the chat history with user [uid].
  AsyncEither<uh.Document> fetchChatHistory(String uid, {int? page}) => AsyncEither(() async {
    final respEither = await getIt.get<NetClientProvider>().get(formatChatFullHistoryUrl(uid, page: page)).run();

    if (respEither.isLeft()) {
      return left(respEither.unwrapErr());
    }
    final resp = respEither.unwrap();
    if (resp.statusCode != HttpStatus.ok) {
      return left(HttpRequestFailedException(resp.statusCode));
    }
    final document = parseHtmlDocument(resp.data as String);
    return right(document);
  });

  /// Fetch the chat history with user [uid].
  AsyncEither<uh.Document> fetchChat(String uid) => AsyncEither(() async {
    final respEither = await getIt.get<NetClientProvider>().get(formatChatUrl(uid)).run();

    if (respEither.isLeft()) {
      return left(respEither.unwrapErr());
    }
    final resp = respEither.unwrap();
    if (resp.statusCode != HttpStatus.ok) {
      return left(HttpRequestFailedException(resp.statusCode));
    }
    final xmlDoc = parseXmlDocument(resp.data as String);
    final htmlBodyData = xmlDoc.documentElement?.nodes.firstOrNull?.text;
    if (htmlBodyData == null) {
      return left(ChatDataDocumentNotFoundException());
    }
    final document = parseHtmlDocument(htmlBodyData);
    return right(document);
  });
}
