import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tsdm_client/models/normal_thread.dart';
import 'package:tsdm_client/routes/app_routes.dart';
import 'package:tsdm_client/themes/widget_themes.dart';
import 'package:tsdm_client/utils/time.dart';
import 'package:tsdm_client/widgets/space.dart';

/// Card to show thread info.
class ThreadCard extends ConsumerWidget {
  /// Constructor.
  ThreadCard(this.thread, {super.key});

  /// Thread data.
  final NormalThread thread;

  /// Current [DateTime] to check time distance.
  final _currentTime = DateTime.now();

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
                    child: TextButton(
                      onPressed: () {
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
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          thread.title,
                          style: headerTextStyle(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              GridView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 170,
                  mainAxisExtent: 35,
                ),
                children: [
                  TextButton.icon(
                    icon: const Icon(
                      Icons.perm_identity,
                      size: smallIconSize,
                    ),
                    label: Text(
                      thread.author.name,
                      style: const TextStyle(fontSize: smallTextSize),
                    ),
                    style: const ButtonStyle(
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () {},
                  ),
                  Tooltip(
                    message:
                        DateFormat('yyyy-MM-dd').format(thread.publishDate),
                    child: TextButton.icon(
                      icon: const Icon(
                        Icons.access_time,
                        size: smallIconSize,
                      ),
                      label: Text(
                        DateFormat('yyyy-MM-dd').format(thread.publishDate),
                        style: const TextStyle(fontSize: smallTextSize),
                      ),
                      style: const ButtonStyle(
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(
                      Icons.forum,
                      size: smallIconSize,
                    ),
                    label: Text(
                      '${thread.replyCount}',
                      style: const TextStyle(fontSize: smallTextSize),
                    ),
                    style: const ButtonStyle(
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () {},
                  ),
                  TextButton.icon(
                    icon: const Icon(
                      Icons.signal_cellular_alt,
                      size: smallIconSize,
                    ),
                    label: Text(
                      '${thread.viewCount}',
                      style: const TextStyle(fontSize: smallTextSize),
                    ),
                    style: const ButtonStyle(
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () {},
                  ),
                  TextButton.icon(
                    icon: const Icon(
                      Icons.record_voice_over,
                      size: smallIconSize,
                    ),
                    label: Text(
                      thread.latestReplyAuthor.name,
                      style: const TextStyle(fontSize: smallTextSize),
                    ),
                    style: const ButtonStyle(
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () {},
                  ),
                  Tooltip(
                    message: DateFormat('yyyy-MM-dd hh:mm:ss')
                        .format(thread.latestReplyTime),
                    child: TextButton.icon(
                      icon: const Icon(
                        Icons.hourglass_bottom,
                        size: smallIconSize,
                      ),
                      label: Text(
                        timeDifferenceToString(
                            _currentTime, thread.latestReplyTime),
                        style: const TextStyle(fontSize: smallTextSize),
                      ),
                      style: const ButtonStyle(
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
