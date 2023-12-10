import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/notice.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/widgets/cached_image_provider.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

class NoticeCard extends ConsumerWidget {
  const NoticeCard({required this.notice, super.key});

  final Notice notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final CircleAvatar userAvatar;
    if (notice.userAvatarUrl != null) {
      userAvatar = CircleAvatar(
        backgroundImage: CachedImageProvider(
          notice.userAvatarUrl!,
          context,
          ref,
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
      NoticeType.rate => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t.noticePage.noticeTab.rateBody(
                threadTitle: notice.noticeThreadTitle ?? '-',
                score: notice.score ?? '-',
              ),
            ),
            Card(
              elevation: 2,
              child: Padding(
                padding: edgeInsetsL15T15R15B15,
                child: Text(notice.quotedMessage ?? ''),
              ),
            )
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
    };

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: notice.redirectUrl != null
            ? () async {
                await context.pushNamed(ScreenPaths.reply,
                    pathParameters: <String, String>{
                      'target': notice.redirectUrl!,
                    });
              }
            : null,
        child: Column(
          children: [
            ListTile(
              leading: userAvatar,
              title: SingleLineText(notice.username ?? ''),
              subtitle: SingleLineText(notice.noticeTime?.yyyyMMDD() ?? ''),
            ),
            sizedBoxW5H5,
            Padding(
              padding: edgeInsetsL15R15B10,
              child: Row(
                children: [
                  Expanded(
                    child: noticeBody,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
