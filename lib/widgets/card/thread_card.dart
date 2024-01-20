import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/latest_thread/models/latest_thread.dart';
import 'package:tsdm_client/features/my_thread/models/my_thread.dart';
import 'package:tsdm_client/features/search/models/searched_thread.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/css_types.dart';
import 'package:tsdm_client/shared/models/normal_thread.dart';
import 'package:tsdm_client/shared/models/thread_type.dart';
import 'package:tsdm_client/shared/models/user.dart';
import 'package:tsdm_client/themes/widget_themes.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

class _CardLayout extends StatelessWidget {
  const _CardLayout({
    required this.threadID,
    required this.title,
    required this.author,
    this.publishTime,
    this.threadType,
    this.replyCount,
    this.viewCount,
    this.latestReplyTime,
    this.price,
    this.quotedMessage,
    this.css,
    this.stateSet,
  });

  final String threadID;
  final String title;
  final ThreadType? threadType;
  final User author;
  final DateTime? publishTime;

  final int? replyCount;
  final int? viewCount;
  final DateTime? latestReplyTime;
  final int? price;
  final String? quotedMessage;
  final CssTypes? css;
  final Set<ThreadState>? stateSet;

  @override
  Widget build(BuildContext context) {
    final infoList = [
      if (replyCount != null) (Icons.forum_outlined, '$replyCount'),
      if (viewCount != null) (Icons.bar_chart_outlined, '$viewCount'),
      // (Icons.person_outline, thread.latestReplyAuthor.name),
      if (latestReplyTime != null)
        (
          Icons.timelapse_outlined,
          latestReplyTime!.elapsedTillNow(),
        ),
      if ((price ?? 0) > 0) (FontAwesomeIcons.coins, '$price'),
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
              'tid': threadID,
            },
            queryParameters: {
              'appBarTitle': title,
              'threadType': threadType?.name,
            },
          );
        },
        child: Column(
          children: [
            // TODO: Tap to navigate to user space.
            ListTile(
              leading: GestureDetector(
                onTap: () async => context.dispatchAsUrl(author.url),
                child: CircleAvatar(
                  child: Text(author.name[0]),
                ),
              ),
              title: Row(
                children: [
                  GestureDetector(
                    onTap: () async => context.dispatchAsUrl(author.url),
                    child: SingleLineText(author.name),
                  ),
                  Expanded(child: Container()),
                ],
              ),
              subtitle: publishTime != null
                  ? SingleLineText(publishTime!.yyyyMMDD())
                  : null,
              trailing: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (stateSet != null)
                    ...stateSet!.map((e) => Icon(e.icon, size: 16)),
                  Text(threadType?.name ?? ''),
                ].insertBetween(sizedBoxW5H5),
              ),
            ),
            Padding(
              padding: edgeInsetsL15R15B10,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: css?.color,
                        fontWeight: css?.fontWeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (quotedMessage != null)
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: edgeInsetsL15T15R15B15,
                        child: Text(quotedMessage!),
                      ),
                    ),
                  ),
                ],
              ),
            if (infoWidgetList.isNotEmpty)
              Padding(
                padding: edgeInsetsL15R15B10,
                child: Row(
                  children: infoWidgetList,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),
          ].insertBetween(sizedBoxW10H10),
        ),
      ),
    );
  }
}

/// Card to show thread info.
class NormalThreadCard extends StatelessWidget {
  /// Constructor.
  const NormalThreadCard(this.thread, {super.key});

  /// Thread data.
  final NormalThread thread;

  @override
  Widget build(BuildContext context) {
    return _CardLayout(
      threadID: thread.threadID,
      title: thread.title,
      author: thread.author,
      publishTime: thread.publishDate,
      threadType: thread.threadType,
      replyCount: thread.replyCount,
      viewCount: thread.viewCount,
      latestReplyTime: thread.latestReplyTime,
      price: thread.price,
      css: thread.css,
      stateSet: thread.stateSet,
    );
  }
}

/// Card to show a thread in search result.
class SearchedThreadCard extends StatelessWidget {
  const SearchedThreadCard(this.thread, {super.key});

  final SearchedThread thread;

  @override
  Widget build(BuildContext context) {
    return _CardLayout(
      threadID: '${thread.threadID}',
      title: thread.title,
      author: thread.author,
      publishTime: thread.publishTime,
    );
  }
}

/// Card to show current user's thread info in "My Thread" page.
class MyThreadCard extends StatelessWidget {
  const MyThreadCard(this.thread, {super.key});

  final MyThread thread;

  @override
  Widget build(BuildContext context) {
    return _CardLayout(
      threadID: thread.threadID!,
      title: thread.title!,
      author: thread.latestReplyAuthor!,
      // FIXME: Do not use thread type to represent forum.
      threadType: ThreadType(name: thread.forumName!, url: thread.forumUrl!),
      publishTime: thread.latestReplyTime,
      quotedMessage: thread.quotedMessage,
    );
  }
}

/// Card to show result in "Latest thread" page.
class LatestThreadCard extends StatelessWidget {
  const LatestThreadCard(this.thread, {super.key});

  final LatestThread thread;

  @override
  Widget build(BuildContext context) {
    return _CardLayout(
      threadID: thread.threadID!,
      title: thread.title!,
      author: thread.latestReplyAuthor!,
      // FIXME: Do not use thread type to represent forum.
      threadType: ThreadType(name: thread.forumName!, url: thread.forumUrl!),
      publishTime: thread.latestReplyTime,
      quotedMessage: thread.quotedMessage,
    );
  }
}
