import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository for editing posts.
final class PostEditRepository {
  static const _submitTarget =
      '$baseUrl/forum.php?mod=post&action=edit&extra=&editsubmit=yes';

  /// Fetch edit data from given [url].
  AsyncEither<uh.Document> fetchData(String url) => AsyncEither(() async {
        final resp = await getIt.get<NetClientProvider>().get(url);
        if (resp.statusCode != HttpStatus.ok) {
          return left(HttpRequestFailedException(resp.statusCode));
        }

        final document = parseHtmlDocument(resp.data as String);
        return right(document);
      });

  /// Post some edited content to server. The content is in a certain post, with
  /// additional options provided by server.
  ///
  /// What's more, when editing a thread (means the first floor post in some
  /// thread), additional [threadType] and [threadTitle] are required.
  ///
  /// This method post to a certain target with data in `multipart/form-data`
  /// Content-Type.
  ///
  /// [fid], [tid] and [pid] is used to specify the post we made modification.
  ///
  /// [data] is post content, now in plain text.
  ///
  /// [threadType] is the number (String) of thread type.
  ///
  /// [options] is a map of option-name - option-value pair.
  AsyncVoidEither postEditedContent({
    required String formHash,
    required String postTime,
    required String delattachop,
    required String wysiwyg,
    required String fid,
    required String tid,
    required String pid,
    required String page,
    required String? threadType,
    required String? threadTitle,
    required String data,
    required Map<String, String> options,
  }) =>
      AsyncVoidEither(() async {
        final body = <String, String>{
          'formhash': formHash,
          'posttime': postTime,
          'delattachop': delattachop,
          'wysiwyg': wysiwyg,
          'fid': fid,
          'tid': tid,
          'pid': pid,
          'checkbox': '0',
          'page': page,
          'subject': threadTitle ?? '',
          'message': data,
          'editsubmit': 'true',
          'save': '',
        };
        if (threadType != null) {
          body['typeid'] = threadType;
        }
        for (final entry in options.entries) {
          body[entry.key] = entry.value;
        }
        final resp = await getIt.get<NetClientProvider>().postMultipartForm(
              _submitTarget,
              data: body,
            );
        // When post succeed, server responses 301.
        // If we got a 200, likely we ran into some error.
        if (resp.statusCode == HttpStatus.ok) {
          final document = parseHtmlDocument(resp.data as String);
          return left(
            PostEditFailedToUploadResult(
              document.querySelector('div#messagetext > p')?.innerText ??
                  'unknown error',
            ),
          );
        }
        if (resp.statusCode != HttpStatus.movedPermanently) {
          return left(
            HttpRequestFailedException(resp.statusCode),
          );
        }

        return rightVoid();
      });
}
