import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/post/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository for editing posts.
final class PostEditRepository with LoggerMixin {
  static const _postSubmitTarget =
      '$baseUrl/forum.php?mod=post&action=edit&extra=&editsubmit=yes';

  static String _buildThreadInfoUrl(String fid) =>
      '$homePage?mod=post&action=newthread&fid=$fid';

  static String _buildThreadPostUrl(String fid) =>
      '$homePage?mod=post&action=newthread&fid=$fid&extra=&topicsubmit=yes';

  /// Fetch edit data from given [url].
  AsyncEither<uh.Document> fetchData(String url) => getIt
      .get<NetClientProvider>()
      .get(url)
      .mapHttp((v) => parseHtmlDocument(v.data as String));

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
    required String save,
    required String? perm,
    required int? price,
  }) => AsyncVoidEither(() async {
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
      'save': save,
      'price': '${price ?? ""}',
    };
    if (threadType != null) {
      body['typeid'] = threadType;
    }
    if (perm != null) {
      body['readperm'] = perm;
    }

    for (final entry in options.entries) {
      body[entry.key] = entry.value;
    }
    final respEither =
        await getIt
            .get<NetClientProvider>()
            .postMultipartForm(_postSubmitTarget, data: body)
            .run();
    if (respEither.isLeft()) {
      return left(respEither.unwrapErr());
    }
    final resp = respEither.unwrap();
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
      return left(HttpRequestFailedException(resp.statusCode));
    }

    return rightVoid();
  });

  /// Fetch required info that used in posting new thread.
  ///
  /// This step is far before posting final thread content to server.
  AsyncEither<uh.Document> prepareInfo(String fid) => getIt
      .get<NetClientProvider>()
      .get(_buildThreadInfoUrl(fid))
      .mapHttp((v) => parseHtmlDocument(v.data as String));

  /// Post new thread data to server.
  ///
  /// Generally the serer will response a status code of 301 with location in
  /// header to redirect to published thread page.
  AsyncEither<String> postThread(ThreadPublishInfo info) => AsyncEither(
    () async {
      switch (await getIt
          .get<NetClientProvider>()
          .postForm(_buildThreadPostUrl(info.fid), data: info.toPostPayload())
          .run()) {
        // Intended into this branch:
        // Server response 301 and dio considered it as an error.
        case Left(:final value)
            when value is HttpHandshakeFailedException &&
                value.statusCode == HttpStatus.movedPermanently &&
                (value.headers?.value(HttpHeaders.locationHeader)?.isNotEmpty ??
                    false):
          return Right(value.headers!.value(HttpHeaders.locationHeader)!);
        case Left(:final value):
          return left(value);
        case Right(:final value) when value.statusCode == HttpStatus.ok:
          return left(
            ThreadPublishFailedException(
              HttpStatus.ok,
              message:
                  parseHtmlDocument(
                    value.data as String,
                  ).querySelector('div#messagetext > p')?.innerText,
            ),
          );
        case Right(:final value)
            when value.statusCode != HttpStatus.movedPermanently:
          return left(ThreadPublishFailedException(value.statusCode!));
        case Right(:final value):
          if (value.headers.map.containsKey(HttpHeaders.locationHeader)) {
            error('location header not found in response');
            return left(ThreadPublishLocationNotFoundException());
          }
          final locations = value.headers.map[HttpHeaders.locationHeader];
          if (locations?.isEmpty ?? true) {
            error('empty location header');
            return left(ThreadPublishLocationNotFoundException());
          }
          return right(locations!.first);
      }
    },
  );
}
