import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/forum.dart';
import '../routes/app_routes.dart';
import '../themes/widget_themes.dart';
import 'network_indicator_image.dart';
import 'space.dart';

/// Card to show forum information.
class ForumCard extends ConsumerWidget {
  /// Constructor.
  ForumCard(this.forum, {super.key}) {
    _buildLatestInfoLine =
        !(forum.latestThreadTime == null && forum.threadTodayCount == null);
  }

  /// Forum id.
  final Forum forum;

  late final bool _buildLatestInfoLine;

  Widget _buildLatestInfoRow(BuildContext context, WidgetRef ret) {
    final itemList = <Widget>[];
    final latestItems = [
      const Icon(
        Icons.access_time,
        size: smallIconSize,
      ),
      Text('最近：${forum.latestThreadTimeText}'),
    ];
    final todayItems = [
      const Icon(
        Icons.campaign,
        size: smallIconSize,
      ),
      Text('新帖：${forum.threadTodayCount}'),
    ];
    if (forum.latestThreadTime != null) {
      itemList.addAll(latestItems);
    }
    if (forum.threadTodayCount != null) {
      if (itemList.isNotEmpty) {
        itemList.add(smallSpacing);
      }
      itemList.addAll(todayItems);
    }
    return Row(
      children: itemList,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
        child: ListTile(
          leading: SizedBox(
            width: 100,
            height: 50,
            child: NetworkIndicatorImage(forum.iconUrl),
          ),
          title: Text(
            forum.name,
            style: headerTextStyle(context),
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
          subtitle: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.chat_bubble,
                    size: smallIconSize,
                  ),
                  Text('主题：${forum.threadCount}'),
                  smallSpacing,
                  const Icon(Icons.forum, size: smallIconSize),
                  Text('贴数：${forum.replyCount}'),
                ],
              ),
              if (_buildLatestInfoLine) _buildLatestInfoRow(context, ref),
            ],
          ),
          isThreeLine: _buildLatestInfoLine,
          onTap: () {
            context.pushNamed(
              TClientRoute.forum,
              pathParameters: <String, String>{
                'fid': '${forum.forumID}',
              },
              extra: <String, String>{
                'appBarTitle': forum.name,
              },
            );
          },
        ),
      );
}
