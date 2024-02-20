import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/notification/models/notice.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

/// Widget to show a single [Notice].
class NoticeCard extends StatelessWidget {
  /// Constructor.
  const NoticeCard({required this.notice, super.key});

  /// Notice model.
  final Notice notice;

  @override
  Widget build(BuildContext context) {
    final outlineStyle = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(color: Theme.of(context).colorScheme.outline);

    late final CircleAvatar userAvatar;
    if (notice.userAvatarUrl != null) {
      userAvatar = CircleAvatar(
        backgroundImage: CachedImageProvider(
          notice.userAvatarUrl!,
          context,
          fallbackImageUrl: noAvatarUrl,
        ),
      );
    } else {
      userAvatar = CircleAvatar(child: Text(notice.username?[0] ?? ''));
    }

    final noticeBody = switch (notice.noticeType) {
      NoticeType.reply => Text(
          context.t.noticePage.noticeTab
              .replyBody(threadTitle: notice.noticeThreadTitle ?? '-'),
        ),
      NoticeType.rate || NoticeType.batchRate => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t.noticePage.noticeTab.rateBody(
                threadTitle: notice.noticeThreadTitle ?? '-',
                score: notice.score ?? '-',
              ),
            ),
            if (notice.quotedMessage?.isNotEmpty ?? false)
              Card(
                elevation: 2,
                child: Padding(
                  padding: edgeInsetsL15T15R15B15,
                  child: Text(notice.quotedMessage!),
                ),
              ),
            if (notice.taskId != null) sizedBoxW5H5,
            if (notice.taskId != null)
              Text(
                context.t.noticePage.noticeTab.taskID(taskId: notice.taskId!),
                style: outlineStyle,
              ),
          ],
        ),
      NoticeType.mention => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.t.noticePage.noticeTab.mentionBody),
            Card(
              elevation: 2,
              child: Padding(
                padding: edgeInsetsL15T15R15B15,
                child: Text(notice.quotedMessage ?? ''),
              ),
            ),
          ],
        ),
      NoticeType.invite => Text(
          context.t.noticePage.noticeTab
              .inviteBody(threadTitle: notice.noticeThreadTitle ?? ''),
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
                    : () async => context.dispatchAsUrl(notice.userSpaceUrl!),
                child: userAvatar,
              ),
              title: GestureDetector(
                onTap: notice.userSpaceUrl == null
                    ? null
                    : () async => context.dispatchAsUrl(notice.userSpaceUrl!),
                child: Row(children: [SingleLineText(notice.username ?? '')]),
              ),
              trailing: Text(notice.noticeTimeString),
              subtitle: SingleLineText(notice.noticeTime?.yyyyMMDD() ?? ''),
            ),
            sizedBoxW5H5,
            Padding(
              padding: edgeInsetsL15R15B10,
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
                ].insertBetween(sizedBoxW5H5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
