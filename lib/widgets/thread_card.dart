import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tsdm_client/models/normal_thread.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/themes/widget_themes.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

/// Card to show thread info.
class ThreadCard extends ConsumerWidget {
  /// Constructor.
  ThreadCard(this.thread, {super.key});

  /// Thread data.
  final NormalThread thread;

  /// Current [DateTime] to check time distance.
  final _currentTime = DateTime.now();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoList = [
      (Icons.tag, thread.threadType!.name),
      (Icons.forum_outlined, '${thread.replyCount}'),
      (Icons.bar_chart_outlined, '${thread.viewCount}'),
      // TODO: Add these for large layout.
      // (Icons.person_outline, thread.latestReplyAuthor.name),
      // (
      //   Icons.timelapse_outlined,
      //   thread.latestReplyTime == null
      //       ? ''
      //       : timeDifferenceToString(_currentTime, thread.latestReplyTime!),
      // ),
    ];

    final infoWidgetList = <Widget>[];
    for (final e in infoList) {
      infoWidgetList.add(
        Expanded(
          child: Row(
            children: [
              Icon(e.$1, size: smallIconSize),
              const SizedBox(width: 5),
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
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(
          thread.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: infoWidgetList,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 70,
              child: SingleLineText(
                thread.author.name,
                textAlign: TextAlign.end,
              ),
            ),
            if (thread.publishDate != null) ...[
              const SizedBox(height: 5),
              SizedBox(
                width: 70,
                child: SingleLineText(
                  DateFormat('yyyy-MM-dd').format(thread.publishDate!),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          context.pushNamed(
            ScreenPaths.thread,
            pathParameters: <String, String>{
              'tid': thread.threadID,
            },
            extra: <String, dynamic>{
              'appBarTitle': thread.title,
            },
          );
        },
      ),
    );
  }
}
