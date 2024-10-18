import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:universal_html/parsing.dart';

/// Widgets in this file are for models fetched through notification APIs.
///
/// Those models are the ones fetched through APIs.
///
/// Compare with the original v1 version, now all these notices are more
/// concrete.
///
/// Likely specialize the layout for all known messages is possible, but
/// currently only use a more normal layout to ensure all kinds of messages are
/// parsed successfully.

/// Widget to display data in [NoticeV2].
class NoticeCardV2 extends StatelessWidget {
  /// Constructor.
  const NoticeCardV2(this.data, {super.key});

  /// Data to display.
  final NoticeV2 data;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.notifications_outlined),
            ),
            title: Text(context.t.noticePage.noticeTab.title),
            subtitle: Text(
              // Timestamp in second.
              DateTime.fromMillisecondsSinceEpoch(data.timestamp * 1000)
                  .yyyyMMDDHHMMSS(),
            ),
          ),
          Padding(
            padding: edgeInsetsL16R16B12,
            child: munchElement(context, parseHtmlDocument(data.data).body!),
          ),
        ],
      ),
    );
  }
}

/// Widget to display personal message stored in [PersonalMessageV2].
class PersonalMessageCardV2 extends StatelessWidget {
  /// Constructor.
  const PersonalMessageCardV2(this.data, {super.key});

  /// Data to display.
  final PersonalMessageV2 data;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async => context.pushNamed(
          ScreenPaths.chatHistory,
          pathParameters: {'uid': '${data.peerUid}'},
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.message_outlined),
              ),
              title: Text(data.peerUsername),
              subtitle: Text(
                // Timestamp in second.
                DateTime.fromMillisecondsSinceEpoch(data.timestamp * 1000)
                    .yyyyMMDDHHMMSS(),
              ),
            ),
            Padding(
              padding: edgeInsetsL16R16B12,
              child: munchElement(context, parseHtmlDocument(data.data).body!),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display broadcast message in [BroadcastMessageV2].
class BroadcastMessageCardV2 extends StatelessWidget {
  /// Constructor.
  const BroadcastMessageCardV2(this.data, {super.key});

  static const _detailPageUrl =
      '$baseUrl/home.php?mod=space&do=pm&subop=viewg&pmid=';

  /// Data to display.
  final BroadcastMessageV2 data;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async => context.dispatchAsUrl('$_detailPageUrl${data.pmid}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.campaign_outlined)),
              title: Text(context.t.noticePage.broadcastMessageTab.system),
              subtitle: Text(
                // Timestamp in second.
                DateTime.fromMillisecondsSinceEpoch(data.timestamp * 1000)
                    .yyyyMMDDHHMMSS(),
              ),
            ),
            Padding(
              padding: edgeInsetsL16R16B12,
              child: munchElement(context, parseHtmlDocument(data.data).body!),
            ),
          ],
        ),
      ),
    );
  }
}
