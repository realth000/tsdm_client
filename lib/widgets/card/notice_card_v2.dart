import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/notification/bloc/notification_bloc.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:tsdm_client/utils/html/munch_options.dart';
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
class NoticeCardV2 extends StatefulWidget {
  /// Constructor.
  const NoticeCardV2(this.data, {super.key});

  /// Data to display.
  final NoticeV2 data;

  @override
  State<NoticeCardV2> createState() => _NoticeCardV2State();
}

class _NoticeCardV2State extends State<NoticeCardV2> {
  bool alreadyRead = false;

  void _onUrlLaunched() {
    // Update state to read if any link in rendered html launched.
    if (alreadyRead || !context.mounted) {
      return;
    }
    setState(() {
      alreadyRead = true;
    });
    final uid = context.read<AuthenticationRepository>().currentUser?.uid;
    if (uid == null) {
      return;
    }
    context.read<NotificationBloc>().add(
          NotificationMarkReadRequested(
            RecordMarkNotice(
              uid: uid,
              nid: widget.data.id,
              alreadyRead: true,
            ),
          ),
        );
  }

  @override
  void initState() {
    super.initState();
    alreadyRead = widget.data.alreadyRead;
  }

  @override
  Widget build(BuildContext context) {
    final showBadge =
        getIt.get<SettingsRepository>().currentSettings.showUnreadNoticeBadge;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Badge(
              isLabelVisible: showBadge && !alreadyRead,
              child: const CircleAvatar(
                child: Icon(Icons.notifications_outlined),
              ),
            ),
            title: Text(context.t.noticePage.noticeTab.title),
            subtitle: Text(
              // Timestamp in second.
              DateTime.fromMillisecondsSinceEpoch(widget.data.timestamp * 1000)
                  .yyyyMMDDHHMMSS(),
            ),
          ),
          Padding(
            padding: edgeInsetsL16R16B12,
            child: munchElement(
              context,
              parseHtmlDocument(widget.data.data).body!,
              options: MunchOptions(onUrlLaunched: _onUrlLaunched),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display personal message stored in [PersonalMessageV2].
class PersonalMessageCardV2 extends StatefulWidget {
  /// Constructor.
  const PersonalMessageCardV2(this.data, {super.key});

  /// Data to display.
  final PersonalMessageV2 data;

  @override
  State<PersonalMessageCardV2> createState() => _PersonalMessageCardV2State();
}

class _PersonalMessageCardV2State extends State<PersonalMessageCardV2> {
  bool alreadyRead = false;

  Future<void> _onTap(BuildContext context) async {
    final uid = context.read<AuthenticationRepository>().currentUser?.uid;

    await context.pushNamed(
      ScreenPaths.chatHistory,
      pathParameters: {'uid': '${widget.data.peerUid}'},
    );

    if (alreadyRead || !context.mounted) {
      return;
    }
    setState(() {
      alreadyRead = true;
    });
    if (uid == null) {
      return;
    }
    context.read<NotificationBloc>().add(
          NotificationMarkReadRequested(
            RecordMarkPersonalMessage(
              uid: uid,
              peerUid: widget.data.peerUid,
              alreadyRead: true,
            ),
          ),
        );
  }

  @override
  void initState() {
    super.initState();
    alreadyRead = widget.data.alreadyRead;
  }

  @override
  Widget build(BuildContext context) {
    final showBadge = getIt
        .get<SettingsRepository>()
        .currentSettings
        .showUnreadPersonalMessageBadge;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async => _onTap(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Badge(
                isLabelVisible: showBadge && !alreadyRead,
                child: const CircleAvatar(
                  child: Icon(Icons.message_outlined),
                ),
              ),
              title: Text(widget.data.peerUsername),
              subtitle: Text(
                // Timestamp in second.
                DateTime.fromMillisecondsSinceEpoch(
                  widget.data.timestamp * 1000,
                ).yyyyMMDDHHMMSS(),
              ),
            ),
            Padding(
              padding: edgeInsetsL16R16B12,
              child: munchElement(
                context,
                parseHtmlDocument(widget.data.data).body!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display broadcast message in [BroadcastMessageV2].
class BroadcastMessageCardV2 extends StatefulWidget {
  /// Constructor.
  const BroadcastMessageCardV2(this.data, {super.key});

  static const _detailPageUrl =
      '$baseUrl/home.php?mod=space&do=pm&subop=viewg&pmid=';

  /// Data to display.
  final BroadcastMessageV2 data;

  @override
  State<BroadcastMessageCardV2> createState() => _BroadcastMessageCardV2State();
}

class _BroadcastMessageCardV2State extends State<BroadcastMessageCardV2> {
  bool alreadyRead = false;

  Future<void> _onTap(BuildContext context) async {
    final uid = context.read<AuthenticationRepository>().currentUser?.uid;
    await context.dispatchAsUrl(
      '${BroadcastMessageCardV2._detailPageUrl}${widget.data.pmid}',
    );
    if (alreadyRead || !context.mounted) {
      return;
    }
    setState(() {
      alreadyRead = true;
    });
    if (uid == null) {
      return;
    }
    context.read<NotificationBloc>().add(
          NotificationMarkReadRequested(
            RecordMarkBroadcastMessage(
              uid: uid,
              timestamp: widget.data.timestamp,
              alreadyRead: true,
            ),
          ),
        );
  }

  @override
  void initState() {
    super.initState();
    alreadyRead = widget.data.alreadyRead;
  }

  @override
  Widget build(BuildContext context) {
    final showBadge = getIt
        .get<SettingsRepository>()
        .currentSettings
        .showUnreadBroadcastMessageBadge;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async => _onTap(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Badge(
                isLabelVisible: showBadge && !alreadyRead,
                child: const CircleAvatar(child: Icon(Icons.campaign_outlined)),
              ),
              title: Text(context.t.noticePage.broadcastMessageTab.system),
              subtitle: Text(
                // Timestamp in second.
                DateTime.fromMillisecondsSinceEpoch(
                  widget.data.timestamp * 1000,
                ).yyyyMMDDHHMMSS(),
              ),
            ),
            Padding(
              padding: edgeInsetsL16R16B12,
              child: munchElement(
                context,
                parseHtmlDocument(widget.data.data).body!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
