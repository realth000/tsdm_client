import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/providers/small_providers.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

part '../generated/providers/html_parser_provider.g.dart';

@Riverpod()
class HtmlParser extends _$HtmlParser {
  @override
  void build() {}

  uh.HtmlDocument parseResp<T>(Response<T> resp) {
    final doc = parseHtmlDocument((resp.data ?? '') as String);
    final serverTime = doc
            .querySelector('p.xs0')
            ?.childNodes
            .elementAtOrNull(0)
            ?.text
            ?.split(',')
            .lastOrNull
            ?.trim()
            .parseToDateTimeUtc8() ??
        DateTime.now();
    ref.read(serverDateTimeProvider.notifier).state = serverTime;
    return doc;
  }
}
