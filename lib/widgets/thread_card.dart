import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/normal_thread.dart';
import '../themes/widget_themes.dart';
import 'space.dart';

/// Card to show thread info.
class ThreadCard extends ConsumerWidget {
  /// Constructor.
  const ThreadCard(this.thread, {super.key});

  /// Thread data.
  final NormalThread thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 5, top: 2, right: 5, bottom: 2),
          child: Column(
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(thread.threadType!.name),
                    backgroundColor: Colors.transparent,
                  ),
                  smallSpacing,
                  Expanded(
                    child: Text(
                      thread.title,
                      style: headerTextStyle(context),
                    ),
                  ),
                ],
              ),
              GridView(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 30,
                ),
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.perm_identity),
                    label: Text('作者：${thread.author.name}'),
                    style: const ButtonStyle(
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () {},
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      smallSpacing,
                      Text(
                        '发布时间：${DateFormat('yyyy-MM-dd').format(thread.publishDate)}',
                      ),
                    ],
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.forum),
                    label: Text('回复：${thread.replyCount}'),
                    style: const ButtonStyle(
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () {},
                  ),
                  Row(
                    children: [
                      const Icon(Icons.signal_cellular_alt),
                      smallSpacing,
                      Text('查看：${thread.viewCount}'),
                    ],
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.record_voice_over),
                    label: Text('最后回复：${thread.latestReplyAuthor.name}'),
                    style: const ButtonStyle(
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () {},
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      smallSpacing,
                      Text(
                          '回复时间：${DateFormat('yyyy-MM-dd hh:mm:ss').format(thread.latestReplyTime)}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
