import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/widgets/heroes.dart';
import 'package:tsdm_client/widgets/quoted_text.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

/// Widget to show a single [Notice].
class NoticeCard extends StatelessWidget {
  /// Constructor.
  const NoticeCard({required this.notice, super.key});

  /// Notice model.
  final Notice notice;

  @override
  Widget build(BuildContext context) {
    final primaryStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Theme.of(context).colorScheme.primary);
    final secondaryStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Theme.of(context).colorScheme.secondary);
    final outlineStyle = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(color: Theme.of(context).colorScheme.outline);
    final heroTag = '${notice.username}-${notice.noticeTime}';

    final noticeBody = switch (notice.noticeType) {
      NoticeType.reply => Text.rich(
          context.t.noticePage.noticeTab.replyBody(
            threadTitle: TextSpan(
              text: notice.noticeThreadTitle ?? '-',
              style: primaryStyle,
            ),
          ),
        ),
      NoticeType.rate || NoticeType.batchRate => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              context.t.noticePage.noticeTab.rateBody(
                threadTitle: TextSpan(
                  text: notice.noticeThreadTitle ?? '-',
                  style: primaryStyle,
                ),
                score: TextSpan(
                  text: notice.score ?? '-',
                  style: secondaryStyle,
                ),
              ),
            ),
            if (notice.quotedMessage?.isNotEmpty ?? false) ...[
              sizedBoxW4H4,
              QuotedText(notice.quotedMessage ?? ''),
            ],
            if (notice.taskId != null) sizedBoxW4H4,
            if (notice.taskId != null)
              Text(
                context.t.noticePage.noticeTab.taskID(taskId: notice.taskId!),
                style: outlineStyle,
              ),
          ],
        ),
      NoticeType.mention => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(context.t.noticePage.noticeTab.mentionBody),
            QuotedText(notice.quotedMessage ?? ''),
          ].insertBetween(sizedBoxW4H4),
        ),
      NoticeType.invite => Text.rich(
          context.t.noticePage.noticeTab.inviteBody(
            threadTitle: TextSpan(
              text: notice.noticeThreadTitle ?? '',
              style: primaryStyle,
            ),
          ),
        ),
      NoticeType.newFriend =>
        Text(context.t.noticePage.noticeTab.newFriendBody),
    };

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: notice.redirectUrl != null
            ? () async {
                // The redirect url in invite type notice is a thread page.
                // Do NOT go to the notice detail page.
                if (notice.noticeType == NoticeType.invite) {
                  return context.dispatchAsUrl(notice.redirectUrl!);
                }

                await context.pushNamed(
                  ScreenPaths.reply,
                  pathParameters: <String, String>{
                    'target': notice.redirectUrl!,
                  },
                  queryParameters: {
                    'noticeType': '${notice.noticeType.index}',
                  },
                );
              }
            : null,
        child: Column(
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: notice.userSpaceUrl == null
                    ? null
                    : () async => context.dispatchAsUrl(
                          notice.userSpaceUrl!,
                          extraQueryParameters: {'hero': heroTag},
                        ),
                child: HeroUserAvatar(
                  username: notice.username ?? '',
                  avatarUrl: notice.userAvatarUrl,
                  heroTag: heroTag,
                ),
              ),
              title: GestureDetector(
                onTap: notice.userSpaceUrl == null
                    ? null
                    : () async => context.dispatchAsUrl(
                          notice.userSpaceUrl!,
                          extraQueryParameters: {'hero': heroTag},
                        ),
                child: Row(children: [SingleLineText(notice.username ?? '')]),
              ),
              trailing: Text(notice.noticeTimeString),
              subtitle: SingleLineText(notice.noticeTime?.yyyyMMDD() ?? ''),
            ),
            sizedBoxW4H4,
            Padding(
              padding: edgeInsetsL16R16B12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [Expanded(child: noticeBody)]),
                  if (notice.ignoreCount != null && notice.ignoreCount! > 0)
                    Text(
                      context.t.noticePage.noticeTab
                          .ignoredSameNotice(count: notice.ignoreCount!),
                      style: outlineStyle,
                    ),
                ].insertBetween(sizedBoxW4H4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
