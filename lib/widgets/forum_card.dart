import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/forum.dart';
import '../routes/app_routes.dart';
import '../themes/widget_themes.dart';
import 'space.dart';

/// Card to show forum information.
class ForumCard extends ConsumerWidget {
  /// Constructor.
  ForumCard({required Forum forum, super.key}) : _forum = forum {
    _buildLatestInfoLine =
        !(_forum.latestThreadTime == null && _forum.threadTodayCount == null);
  }

  /// Forum id.
  final Forum _forum;

  late final bool _buildLatestInfoLine;

  Widget _buildLatestInfoRow(BuildContext context, WidgetRef ret) {
    final itemList = <Widget>[];
    final latestItems = [
      const Icon(
        Icons.access_time,
        size: smallIconSize,
      ),
      Text('最近发表：${_forum.latestThreadTimeText}'),
    ];
    final todayItems = [
      const Icon(
        Icons.campaign,
        size: smallIconSize,
      ),
      Text('今日新帖：${_forum.threadTodayCount}'),
    ];
    if (_forum.latestThreadTime != null) {
      itemList.addAll(latestItems);
    }
    if (_forum.threadTodayCount != null) {
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
            child: Image.network(
              _forum.iconUrl,
            ),
          ),
          title: Text(
            _forum.name,
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
                  Text('主题：${_forum.threadCount}'),
                  smallSpacing,
                  const Icon(Icons.forum, size: smallIconSize),
                  Text('贴数：${_forum.replyCount}'),
                ],
              ),
              if (_buildLatestInfoLine) _buildLatestInfoRow(context, ref),
            ],
          ),
          isThreeLine: _buildLatestInfoLine,
          onTap: () {
            context.pushNamed(
              TClientRoute.forum,
              params: <String, String>{
                'fid': '${_forum.forumID}',
              },
              extra: <String, String>{
                'appBarTitle': _forum.name,
              },
            );
          },
        ),
      );
}
