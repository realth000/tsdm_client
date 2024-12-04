import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/themes/widget_themes.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/widgets/network_indicator_image.dart';

/// Card to show forum information.
class ForumCard extends StatefulWidget {
  /// Constructor.
  const ForumCard(this.forum, {super.key});

  /// Forum id.
  final Forum forum;

  @override
  State<ForumCard> createState() => _ForumCardState();
}

final class _ForumCardState extends State<ForumCard> with LoggerMixin {
  bool showingSubThread = false;
  bool showingSubForum = false;

  Widget _buildShortcut(BuildContext context) {
    return Column(
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
              final target = widget.forum.latestThreadUrl?.parseUrlToRoute();
              if (target == null) {
                error(
                  'invalid latest thread url: '
                  '${widget.forum.latestThreadUrl}',
                );
                return;
              }
              await context.pushNamed(
                target.screenPath,
                pathParameters: target.pathParameters,
                queryParameters: target.queryParameters,
              );
            },
          ),
        if (widget.forum.subThreadList?.isNotEmpty ?? false)
          ..._buildWrapSection(context, context.t.forumCard.links,
              widget.forum.subThreadList!, showingSubThread, () {
            setState(() {
              showingSubThread = !showingSubThread;
            });
          }),
        if (widget.forum.subForumList?.isNotEmpty ?? false)
          ..._buildWrapSection(context, context.t.forumCard.subForums,
              widget.forum.subForumList!, showingSubForum, () {
            setState(() {
              showingSubForum = !showingSubForum;
            });
          }),
      ],
    );
  }

  List<Widget> _buildWrapSection(
    BuildContext context,
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
                target.screenPath,
                pathParameters: target.pathParameters,
                queryParameters: target.queryParameters,
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
          padding: edgeInsetsL8R8,
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
    final settingsStream = getIt.get<SettingsRepository>().settings;
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
      ),
    ];

    final forumInfoWidgets = forumInfoList
        .map(
          (e) => Expanded(
            child: Row(
              children: [
                Icon(e.$1, size: smallIconSize),
                sizedBoxW4H4,
                Flexible(
                  child: Text(
                    '${e.$2}',
                    style: const TextStyle(fontSize: smallTextSize),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await context.pushNamed(
            ScreenPaths.forum,
            pathParameters: <String, String>{
              'fid': '${widget.forum.forumID}',
            },
            queryParameters: {
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
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
              ),
              subtitle: widget.forum.latestThreadTime != null
                  ? Text(
                      widget.forum.latestThreadTime!.elapsedTillNow(context),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  : null,
            ),
            StreamBuilder(
              stream: settingsStream,
              builder: (context, settings) {
                if (!settings.hasData) {
                  return const SizedBox.shrink();
                }
                if (settings.data!.showShortcutInForumCard) {
                  return _buildShortcut(context);
                }
                return const SizedBox.shrink();
              },
            ),
            Padding(
              padding: edgeInsetsL16R16B12,
              child: Column(
                children: [
                  sizedBoxW12H12,
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
