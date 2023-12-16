import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/latest_thread.dart';
import 'package:tsdm_client/widgets/refresh_list.dart';
import 'package:tsdm_client/widgets/thread_card.dart';

class LatestThreadPage extends ConsumerWidget {
  const LatestThreadPage({required this.url, super.key});

  /// Url to fetch the latest thread data.
  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.latestThreadPage.title),
      ),
      body: RefreshList<LatestThread>(
        targetUrl: url,
        buildDataCallback: (document) {
          final data = document
              .querySelector('div#threadlist > ul')
              ?.querySelectorAll('li')
              .map(LatestThread.fromLi)
              .where((e) => e.isValid())
              .toList();
          return data ?? [];
        },
        parseNextPageUrlCallback: (document) {
          return document
              .querySelector('div#ct_shell div.pg > a.nxt')
              ?.firstHref();
        },
        builder: (data) {
          return LatestThreadCard(data);
        },
      ),
    );
  }
}
