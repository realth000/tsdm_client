import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/my_thread.dart';
import 'package:tsdm_client/widgets/refresh_list.dart';
import 'package:tsdm_client/widgets/thread_card.dart';

/// Page to show "My thread" page on website.
/// https://tsdm39.com/home.php?mod=space&do=thread&view=me
class MyThreadPage extends ConsumerStatefulWidget {
  const MyThreadPage({super.key});

  @override
  ConsumerState<MyThreadPage> createState() => _MyThreadPageState();
}

class _MyThreadPageState extends ConsumerState<MyThreadPage>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  Widget _buildThreadTab(BuildContext context) {
    return Padding(
      padding: edgeInsetsL10T5R10B20,
      child: RefreshList<MyThread>(
        targetUrl: myThreadThreadUrl,
        buildDataCallback: (document) async {
          final data = document
              .querySelectorAll(
                  'div.bm.bw0 > div.tl > form > table > tbody > tr')
              .skip(1)
              .map(MyThread.fromTr)
              .where((e) => e.isValid())
              .toList();
          return data;
        },
        parseNextPageUrlCallback: (document) async {
          return document
              .querySelector('div.pgs.cl.mtm > div.pg > a.nxt')
              ?.firstHref()
              ?.prependHost();
        },
        builder: (data) {
          return MyThreadCard(data);
        },
      ),
    );
  }

  Widget _buildReplyTab(BuildContext context) {
    return Padding(
      padding: edgeInsetsL10T5R10B20,
      child: RefreshList<MyThread>(
        targetUrl: myThreadReplyUrl,
        buildDataCallback: (document) async {
          final data = document
              .querySelectorAll(
                  'div.bm.bw0 > div.tl > form > table > tbody > tr.bw0_all')
              .skip(1)
              .map(MyThread.fromTr)
              .where((e) => e.isValid())
              .toList();
          return data;
        },
        parseNextPageUrlCallback: (document) async {
          return document
              .querySelector('div.pgs.cl.mtm > div.pg > a.nxt')
              ?.firstHref()
              ?.prependHost();
        },
        builder: (data) {
          return MyThreadCard(data);
        },
      ),
    );
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tabController ??= TabController(length: 2, vsync: this);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.myThreadPage.title),
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(child: Text(context.t.myThreadPage.threadTab.title)),
            Tab(child: Text(context.t.myThreadPage.replyTab.title))
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildThreadTab(context),
          _buildReplyTab(context),
        ],
      ),
    );
  }
}
