import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/models/forum.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/themes/widget_themes.dart';
import 'package:tsdm_client/utils/time.dart';
import 'package:tsdm_client/widgets/network_indicator_image.dart';

/// Card to show forum information.
class ForumCard extends ConsumerWidget {
  /// Constructor.
  ForumCard(this.forum, {super.key}) : _currentTime = DateTime.now();

  /// Forum id.
  final Forum forum;
  final DateTime _currentTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forumInfoList = [
      (
        Icons.forum_outlined,
        forum.threadCount,
      ),
      (
        Icons.chat_outlined,
        forum.replyCount,
      ),
      (
        Icons.mark_chat_unread_outlined,
        forum.threadTodayCount ?? 0,
      )
    ];

    final forumInfoWidgets = forumInfoList
        .map(
          (e) => Expanded(
            child: Row(
              children: [
                Icon(e.$1, size: smallIconSize),
                const SizedBox(width: 5, height: 5),
                Flexible(
                  child: Text(
                    '${e.$2}',
                    style: const TextStyle(fontSize: smallTextSize),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                )
              ],
            ),
          ),
        )
        .toList();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            ScreenPaths.forum,
            pathParameters: <String, String>{
              'fid': '${forum.forumID}',
            },
            extra: <String, dynamic>{
              'appBarTitle': forum.name,
            },
          );
        },
        child: Column(
          children: [
            ListTile(
              leading: SizedBox(
                width: 100,
                height: 50,
                child: NetworkIndicatorImage(forum.iconUrl),
              ),
              title: Text(
                forum.name,
                style: headerTextStyle(context),
                maxLines: 2,
              ),
              subtitle: forum.latestThreadTime != null
                  ? Text(timeDifferenceToString(
                      _currentTime,
                      forum.latestThreadTime!,
                    ))
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Row(children: forumInfoWidgets),
            ),
          ],
        ),
      ),
    );
  }
}
