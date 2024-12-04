import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/notification/bloc/notification_bloc.dart';
import 'package:tsdm_client/features/notification/bloc/notification_state_cubit.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:tsdm_client/utils/html/munch_options.dart';
import 'package:tsdm_client/widgets/heroes.dart';
import 'package:universal_html/parsing.dart';

enum _Actions {
  markAsRead,
  markAsUnread,
}

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
  void _onUrlLaunched({required bool markAsRead}) {
    // Update state to read if any link in rendered html launched.
    if (!context.mounted) {
      return;
    }

    if (markAsRead) {
      context.read<NotificationStateCubit>().decreaseNotice();
    } else {
      context.read<NotificationStateCubit>().increaseNotice();
    }

    final uid = context.read<AuthenticationRepository>().currentUser?.uid;
    if (uid == null) {
      return;
    }
    context.read<NotificationBloc>().add(
          NotificationMarkReadRequested(
            RecordMarkNotice(
              uid: uid,
              nid: widget.data.id,
              alreadyRead: markAsRead,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.noticePage.cardMenu;
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
              isLabelVisible: showBadge && !widget.data.alreadyRead,
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
            trailing: PopupMenuButton(
              itemBuilder: (_) => [
                if (!widget.data.alreadyRead)
                  PopupMenuItem(
                    value: _Actions.markAsRead,
                    child: Row(
                      children: [
                        const Icon(Icons.mark_chat_read_outlined),
                        sizedBoxPopupMenuItemIconSpacing,
                        Text(tr.markAsRead),
                      ],
                    ),
                  ),
                if (widget.data.alreadyRead)
                  PopupMenuItem(
                    value: _Actions.markAsUnread,
                    child: Row(
                      children: [
                        const Icon(Icons.mark_chat_unread_outlined),
                        sizedBoxPopupMenuItemIconSpacing,
                        Text(tr.markAsUnread),
                      ],
                    ),
                  ),
              ],
              onSelected: (value) async {
                switch (value) {
                  case _Actions.markAsRead:
                    _onUrlLaunched(markAsRead: true);
                  case _Actions.markAsUnread:
                    _onUrlLaunched(markAsRead: false);
                }
              },
            ),
          ),
          Padding(
            padding: edgeInsetsL16R16B12,
            child: munchElement(
              context,
              parseHtmlDocument(widget.data.data).body!,
              options: MunchOptions(
                onUrlLaunched: () => _onUrlLaunched(
                  markAsRead: true,
                ),
              ),
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
  Future<void> _onTap(
    BuildContext context, {
    required bool markAsRead,
    required bool launch,
  }) async {
    final uid = context.read<AuthenticationRepository>().currentUser?.uid;

    if (launch) {
      await context.pushNamed(
        ScreenPaths.chatHistory,
        pathParameters: {'uid': '${widget.data.peerUid}'},
      );
    }

    if (!context.mounted) {
      return;
    }
    if (markAsRead) {
      context.read<NotificationStateCubit>().decreasePersonalMessage();
    } else {
      context.read<NotificationStateCubit>().increasePersonalMessage();
    }
    if (uid == null) {
      return;
    }
    context.read<NotificationBloc>().add(
          NotificationMarkReadRequested(
            RecordMarkPersonalMessage(
              uid: uid,
              peerUid: widget.data.peerUid,
              alreadyRead: markAsRead,
            ),
          ),
        );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.noticePage.cardMenu;
    final showBadge = getIt
        .get<SettingsRepository>()
        .currentSettings
        .showUnreadPersonalMessageBadge;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async => _onTap(context, markAsRead: true, launch: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Badge(
                isLabelVisible: showBadge && !widget.data.alreadyRead,
                child: HeroUserAvatar(
                  username: widget.data.peerUsername,
                  avatarUrl: null,
                  disableHero: true,
                ),
              ),
              title: Text(widget.data.peerUsername),
              subtitle: Text(
                // Timestamp in second.
                DateTime.fromMillisecondsSinceEpoch(
                  widget.data.timestamp * 1000,
                ).yyyyMMDDHHMMSS(),
              ),
              trailing: PopupMenuButton(
                itemBuilder: (_) => [
                  if (!widget.data.alreadyRead)
                    PopupMenuItem(
                      value: _Actions.markAsRead,
                      child: Row(
                        children: [
                          const Icon(Icons.mark_chat_read_outlined),
                          sizedBoxPopupMenuItemIconSpacing,
                          Text(tr.markAsRead),
                        ],
                      ),
                    ),
                  if (widget.data.alreadyRead)
                    PopupMenuItem(
                      value: _Actions.markAsUnread,
                      child: Row(
                        children: [
                          const Icon(Icons.mark_chat_unread_outlined),
                          sizedBoxPopupMenuItemIconSpacing,
                          Text(tr.markAsUnread),
                        ],
                      ),
                    ),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case _Actions.markAsRead:
                      await _onTap(context, markAsRead: true, launch: false);
                    case _Actions.markAsUnread:
                      await _onTap(context, markAsRead: false, launch: false);
                  }
                },
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
  Future<void> _onTap(
    BuildContext context, {
    required bool markAsRead,
    required bool launch,
  }) async {
    final uid = context.read<AuthenticationRepository>().currentUser?.uid;

    if (launch) {
      await context.dispatchAsUrl(
        '${BroadcastMessageCardV2._detailPageUrl}${widget.data.pmid}',
      );
    }

    if (!context.mounted) {
      return;
    }

    if (markAsRead) {
      context.read<NotificationStateCubit>().decreaseBroadcastMessage();
    } else {
      context.read<NotificationStateCubit>().increaseBroadcastMessage();
    }
    if (uid == null) {
      return;
    }
    context.read<NotificationBloc>().add(
          NotificationMarkReadRequested(
            RecordMarkBroadcastMessage(
              uid: uid,
              timestamp: widget.data.timestamp,
              alreadyRead: markAsRead,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.noticePage.cardMenu;
    final showBadge = getIt
        .get<SettingsRepository>()
        .currentSettings
        .showUnreadBroadcastMessageBadge;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async => _onTap(context, markAsRead: true, launch: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Badge(
                isLabelVisible: showBadge && !widget.data.alreadyRead,
                child: const CircleAvatar(child: Icon(Icons.campaign_outlined)),
              ),
              title: Text(context.t.noticePage.broadcastMessageTab.system),
              subtitle: Text(
                // Timestamp in second.
                DateTime.fromMillisecondsSinceEpoch(
                  widget.data.timestamp * 1000,
                ).yyyyMMDDHHMMSS(),
              ),
              trailing: PopupMenuButton(
                itemBuilder: (_) => [
                  if (!widget.data.alreadyRead)
                    PopupMenuItem(
                      value: _Actions.markAsRead,
                      child: Row(
                        children: [
                          const Icon(Icons.mark_chat_read_outlined),
                          sizedBoxPopupMenuItemIconSpacing,
                          Text(tr.markAsRead),
                        ],
                      ),
                    ),
                  if (widget.data.alreadyRead)
                    PopupMenuItem(
                      value: _Actions.markAsUnread,
                      child: Row(
                        children: [
                          const Icon(Icons.mark_chat_unread_outlined),
                          sizedBoxPopupMenuItemIconSpacing,
                          Text(tr.markAsUnread),
                        ],
                      ),
                    ),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case _Actions.markAsRead:
                      await _onTap(context, markAsRead: true, launch: false);
                    case _Actions.markAsUnread:
                      await _onTap(context, markAsRead: false, launch: false);
                  }
                },
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
