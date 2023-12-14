import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/notice.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/notice_card.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Notice page, shows [Notice] and PrivateMessage of current user.
class NoticePage extends ConsumerStatefulWidget {
  const NoticePage({super.key});

  @override
  ConsumerState<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends ConsumerState<NoticePage> {
  final _allData = <Notice>[];

  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
  );

  void _clearData() {
    setState(_allData.clear);
  }

  Future<List<Notice>> _fetchNotice(String url) async {
    late final uh.Document document;

    while (true) {
      final resp = await ref.read(netClientProvider()).get(url);
      if (resp.statusCode == HttpStatus.ok) {
        document = parseHtmlDocument(resp.data as String);
        break;
      }

      if (!context.mounted) {
        return [];
      }

      await showRetryToast(context);
    }

    // Check if empty
    final emptyNode =
        document.querySelector('div#ct > div.mn > div.bm.bw0 > div.emp');
    if (emptyNode != null) {
      debug('empty notice');
      // No notice here.
      return [];
    }

    final noticeList = document
        .querySelectorAll(
            'div#ct div.mn > div.bm.bw0 > div.xld.xlda > div.nts > dl.cl')
        .map(Notice.fromClNode)
        .where((e) => e.isValid())
        .toList();
    return noticeList;
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.noticePage.title),
      ),
      body: EasyRefresh(
        scrollBehaviorBuilder: (physics) {
          // Should use ERScrollBehavior instead of ScrollConfiguration.of(context)
          return ERScrollBehavior(physics)
              .copyWith(physics: physics, scrollbars: false);
        },
        header: const MaterialHeader(),
        controller: _refreshController,
        refreshOnStart: true,
        onRefresh: () async {
          if (!mounted) {
            return;
          }
          _clearData();
          final data = await Future.wait(
              [_fetchNotice(noticeUrl), _fetchNotice(readNoticeUrl)]);
          final d1 = data[0];
          final d2 = data[1];
          // Filter duplicate notices.
          // Only filter on reply type notices for now.
          final d3 = d1.where((x) => !d2.any(
              (y) => x.redirectUrl != null && y.redirectUrl == x.redirectUrl));
          setState(() {
            _allData
              ..addAll(d3)
              ..addAll(d2);
          });
          _refreshController
            ..finishRefresh()
            ..resetFooter();
        },
        child: Padding(
          padding: edgeInsetsL10T5R10B20,
          child: ListView.separated(
            itemCount: _allData.length,
            itemBuilder: (context, index) {
              return NoticeCard(notice: _allData[index]);
            },
            separatorBuilder: (context, index) => sizedBoxW5H5,
          ),
        ),
      ),
    );
  }
}
