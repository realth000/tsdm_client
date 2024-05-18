import 'dart:io';

import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/chat/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/server_time_provider/server_time_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository to fetch chat related source.
final class ChatRepository {
  /// Constructor.
  const ChatRepository();

  /// Fetch the chat history with user [uid].
  ///
  /// # Exceptions
  ///
  /// * **HttpRequestFailedException** if http request failed.
  Future<uh.Document> fetchChatHistory(String uid, {int? page}) async {
    final resp = await getIt.get<NetClientProvider>().get(
          formatChatFullHistoryUrl(uid, page: page),
        );
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }
    final document = parseHtmlDocument(resp.data as String);
    getIt.get<ServerTimeProvider>().updateServerTimeWithDocument(document);
    return document;
  }

  /// Fetch the chat history with user [uid].
  ///
  /// # Exceptions
  ///
  /// * **HttpRequestFailedException** if http request failed.
  /// * **ChatDataDocumentNotFoundException** if chat html document not found.
  Future<uh.Document> fetchChat(String uid) async {
    final resp = await getIt.get<NetClientProvider>().get(formatChatUrl(uid));
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }
    final xmlDoc = parseXmlDocument(resp.data as String);
    final htmlBodyData = xmlDoc.documentElement?.nodes.firstOrNull?.text;
    if (htmlBodyData == null) {
      throw ChatDataDocumentNotFoundException();
    }
    final document = parseHtmlDocument(htmlBodyData);
    getIt.get<ServerTimeProvider>().updateServerTimeWithDocument(document);
    return document;
  }
}
