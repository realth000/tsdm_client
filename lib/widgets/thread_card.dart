import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/models/normal_thread.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/themes/widget_themes.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

/// Card to show thread info.
class ThreadCard extends ConsumerWidget {
  /// Constructor.
  const ThreadCard(this.thread, {super.key});

  /// Thread data.
  final NormalThread thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoList = [
      (Icons.forum_outlined, '${thread.replyCount}'),
      (Icons.bar_chart_outlined, '${thread.viewCount}'),
      // (Icons.person_outline, thread.latestReplyAuthor.name),
      (
        Icons.timelapse_outlined,
        thread.latestReplyTime == null
            ? ''
            : thread.latestReplyTime!.elapsedTillNow(),
      ),
      if ((thread.price ?? 0) > 0) (FontAwesomeIcons.coins, '${thread.price}'),
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
              'tid': thread.threadID,
            },
            queryParameters: {
              'appBarTitle': thread.title,
              'threadType': thread.threadType?.name,
            },
          );
        },
        child: Column(
          children: [
            // TODO: Tap to navigate to user space.
            ListTile(
              leading: CircleAvatar(
                child: Text(thread.author.name[0]),
              ),
              title: SingleLineText(thread.author.name),
              subtitle: thread.publishDate != null
                  ? SingleLineText(thread.publishDate!.yyyyMMDD())
                  : null,
              trailing: Text(thread.threadType?.name ?? ''),
            ),
            Padding(
              padding: edgeInsetsL15R15B10,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      thread.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            sizedBoxW10H10,
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
