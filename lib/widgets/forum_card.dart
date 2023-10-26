import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/forum.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/themes/widget_themes.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/widgets/network_indicator_image.dart';

/// Card to show forum information.
class ForumCard extends ConsumerStatefulWidget {
  /// Constructor.
  const ForumCard(this.forum, {super.key});

  /// Forum id.
  final Forum forum;

  @override
  ConsumerState<ForumCard> createState() => _ForumCardState();
}

class _ForumCardState extends ConsumerState<ForumCard> {
  bool showingSubThread = false;
  bool showingSubForum = false;

  List<Widget> _buildWrapSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<(String, String)> dataList,
    bool state,
    VoidCallback onPressed,
  ) {
    final wrapChildren = dataList
        .map(
          (e) => ActionChip(
            label: Text(e.$1),
            labelStyle: Theme.of(context).textTheme.labelSmall,
            shape: LinearBorder.start(),
            onPressed: () async {
              final target = e.$2.parseUrlToRoute();
              if (target == null) {
                debug('invalid url : ${e.$2}');
                return;
              }
              await context.pushNamed(
                target.$1,
                pathParameters: target.$2,
              );
            },
          ),
        )
        .toList();

    return [
      ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        trailing: Icon(state ? Icons.expand_less : Icons.expand_more),
        onTap: onPressed,
      ),
      if (state)
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  runAlignment: WrapAlignment.end,
                  children: wrapChildren,
                ),
              ),
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final forumInfoList = [
      (
        Icons.forum_outlined,
        widget.forum.threadCount,
      ),
      (
        Icons.chat_outlined,
        widget.forum.replyCount,
      ),
      (
        Icons.mark_chat_unread_outlined,
        widget.forum.threadTodayCount ?? 0,
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
        onTap: () async {
          await context.pushNamed(
            ScreenPaths.forum,
            pathParameters: <String, String>{
              'fid': '${widget.forum.forumID}',
            },
            extra: <String, dynamic>{
              'appBarTitle': widget.forum.name,
            },
          );
        },
        child: Column(
          children: [
            ListTile(
              leading: SizedBox(
                width: 100,
                height: 50,
                child: NetworkIndicatorImage(widget.forum.iconUrl),
              ),
              title: Text(
                widget.forum.name,
                style: headerTextStyle(context),
                maxLines: 2,
              ),
              subtitle: widget.forum.latestThreadTime != null
                  ? Text(widget.forum.latestThreadTime!.elapsedTillNow())
                  : null,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.forum.isExpanded)
                  ListTile(
                    title: Row(
                      children: [
                        Text(
                          widget.forum.latestThreadTitle ?? '',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Expanded(child: Container()),
                        Text(
                          widget.forum.latestThreadUserName ?? '',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    onTap: () async {
                      final target =
                          widget.forum.latestThreadUrl?.parseUrlToRoute();
                      if (target == null) {
                        debug(
                            'invalid latest thread url: ${widget.forum.latestThreadUrl}');
                        return;
                      }
                      await context.pushNamed(
                        target.$1,
                        pathParameters: target.$2,
                      );
                    },
                  ),
                if (widget.forum.subThreadList?.isNotEmpty ?? false)
                  ..._buildWrapSection(context, ref, context.t.forumCard.links,
                      widget.forum.subThreadList!, showingSubThread, () {
                    setState(() {
                      showingSubThread = !showingSubThread;
                    });
                  }),
                if (widget.forum.subForumList?.isNotEmpty ?? false)
                  ..._buildWrapSection(
                      context,
                      ref,
                      context.t.forumCard.subForums,
                      widget.forum.subForumList!,
                      showingSubForum, () {
                    setState(() {
                      showingSubForum = !showingSubForum;
                    });
                  }),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Column(
                children: [
                  const SizedBox(width: 10, height: 10),
                  Row(children: forumInfoWidgets),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
