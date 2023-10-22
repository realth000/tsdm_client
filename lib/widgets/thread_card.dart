import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tsdm_client/models/normal_thread.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/themes/widget_themes.dart';
import 'package:tsdm_client/utils/time.dart';

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
      (Icons.forum, '${thread.replyCount}'),
      (Icons.signal_cellular_alt, '${thread.viewCount}'),
      (Icons.record_voice_over, thread.latestReplyAuthor.name),
      (
        Icons.hourglass_bottom,
        thread.latestReplyTime == null
            ? ''
            : timeDifferenceToString(_currentTime, thread.latestReplyTime!),
      ),
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: SizedBox(
          width: 90,
          child: Chip(
            label: Text(thread.threadType!.name),
            backgroundColor: Colors.transparent,
          ),
        ),
        title: Text(thread.title),
        subtitle: Row(
          children: infoList
              .map(
                (e) => Expanded(
                    child: Row(
                  children: [
                    Icon(e.$1, size: smallIconSize),
                    const SizedBox(width: 5),

                    /// Wrap in expand to make sure `overflow` in text works.
                    Expanded(
                      child: Text(
                        e.$2,
                        style: const TextStyle(fontSize: smallTextSize),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                )),
              )
              .toList(),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              thread.author.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (thread.publishDate != null)
              Text(DateFormat('yyyy-MM-dd').format(thread.publishDate!)),
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
