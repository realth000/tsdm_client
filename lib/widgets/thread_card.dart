import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/models/normal_thread.dart';
import 'package:tsdm_client/models/searched_thread.dart';
import 'package:tsdm_client/models/thread_type.dart';
import 'package:tsdm_client/models/user.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/themes/widget_themes.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

class _CardLayout extends ConsumerWidget {
  const _CardLayout({
    required this.threadID,
    required this.title,
    required this.author,
    this.publishTime,
    this.threadType,
    this.replyCount,
    this.viewCount,
    this.latestReplyTime,
    this.price,
  });

  final String threadID;
  final String title;
  final ThreadType? threadType;
  final User author;
  final DateTime? publishTime;

  final int? replyCount;
  final int? viewCount;
  final DateTime? latestReplyTime;
  final int? price;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoList = [
      if (replyCount != null) (Icons.forum_outlined, '$replyCount'),
      if (viewCount != null) (Icons.bar_chart_outlined, '$viewCount'),
      // (Icons.person_outline, thread.latestReplyAuthor.name),
      if (latestReplyTime != null)
        (
          Icons.timelapse_outlined,
          latestReplyTime!.elapsedTillNow(),
        ),
      if ((price ?? 0) > 0) (FontAwesomeIcons.coins, '$price'),
    ];

    final infoWidgetList = <Widget>[];
    for (final e in infoList) {
      infoWidgetList.add(
        Expanded(
          child: Row(
            children: [
              Icon(e.$1, size: smallIconSize),
              sizedBoxW5H5,
              Flexible(
                child: Text(
                  e.$2,
                  style: const TextStyle(fontSize: smallTextSize),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await context.pushNamed(
            ScreenPaths.thread,
            pathParameters: <String, String>{
              'tid': threadID,
            },
            queryParameters: {
              'appBarTitle': title,
              'threadType': threadType?.name,
            },
          );
        },
        child: Column(
          children: [
            // TODO: Tap to navigate to user space.
            ListTile(
              leading: CircleAvatar(
                child: Text(author.name[0]),
              ),
              title: SingleLineText(author.name),
              subtitle: publishTime != null
                  ? SingleLineText(publishTime!.yyyyMMDD())
                  : null,
              trailing: Text(threadType?.name ?? ''),
            ),
            Padding(
              padding: edgeInsetsL15R15B10,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            sizedBoxW10H10,
            if (infoWidgetList.isNotEmpty)
              Padding(
                padding: edgeInsetsL15R15B10,
                child: Row(
                  children: infoWidgetList,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Card to show thread info.
class NormalThreadCard extends ConsumerWidget {
  /// Constructor.
  const NormalThreadCard(this.thread, {super.key});

  /// Thread data.
  final NormalThread thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CardLayout(
      threadID: thread.threadID,
      title: thread.title,
      author: thread.author,
      publishTime: thread.publishDate,
      threadType: thread.threadType,
      replyCount: thread.replyCount,
      viewCount: thread.viewCount,
      latestReplyTime: thread.latestReplyTime,
      price: thread.price,
    );
  }
}

/// Card to show a thread in search result.
class SearchedThreadCard extends ConsumerWidget {
  const SearchedThreadCard(this.thread, {super.key});

  final SearchedThread thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CardLayout(
      threadID: '${thread.threadID!}',
      title: thread.title!,
      author: thread.author!,
      publishTime: thread.publishTime,
    );
  }
}
