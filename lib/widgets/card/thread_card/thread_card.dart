import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/uri.dart';
import 'package:tsdm_client/features/latest_thread/models/latest_thread.dart';
import 'package:tsdm_client/features/my_thread/models/models.dart';
import 'package:tsdm_client/features/search/models/models.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/themes/widget_themes.dart';
import 'package:tsdm_client/widgets/heroes.dart';
import 'package:tsdm_client/widgets/quoted_text.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

typedef _ThreadInfo = (IconData, String);

class _CardLayout extends StatelessWidget {
  const _CardLayout({
    required this.threadID,
    required this.title,
    this.forum,
    this.author,
    this.publishTime,
    this.threadType,
    this.replyCount,
    this.viewCount,
    this.lastReplyAuthor,
    this.latestReplyTime,
    this.price,
    this.privilege,
    this.quotedMessage,
    this.css,
    this.stateSet,
    this.disableTap = false,
    this.isRecentThread = false,
  });

  final String threadID;
  final String title;
  final String? forum;
  final ThreadType? threadType;
  final User? author;
  final DateTime? publishTime;

  final int? replyCount;
  final int? viewCount;
  final User? lastReplyAuthor;
  final DateTime? latestReplyTime;
  final int? price;
  final int? privilege;
  final String? quotedMessage;
  final CssTypes? css;
  final Set<ThreadStateModel>? stateSet;
  final bool isRecentThread;

  Card _wrapWithCard(BuildContext context, Widget child) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap:
          disableTap
              ? null
              : () async {
                await context.pushNamed(
                  ScreenPaths.threadV1,
                  // pathParameters: {'id': threadID},
                  // FIXME: Query parameters are not recognized by v2 yet.
                  queryParameters: {
                    'tid': threadID,
                    'appBarTitle': title,
                    'threadTypeName': threadType?.name,
                    'threadTypeID': threadType?.url.tryParseAsUri()?.tryGetQueryParameters()?['typeid'],
                  },
                );
              },
      child: child,
    ),
  );

  /// [author] MUST not be null.
  Widget _buildAvatar(BuildContext context) {
    return HeroUserAvatar(username: author!.name, avatarUrl: author!.avatarUrl, disableHero: true);
  }

  /// Mainly for test.
  final bool disableTap;

  Widget _buildInfoWidgetRow({
    required BuildContext context,
    required bool infoRowAlignCenter,
    required bool showLastReplyAuthor,
    required bool highlightInfoRow,
  }) {
    final infoColor = switch (highlightInfoRow) {
      true => Theme.of(context).colorScheme.secondary,
      false => null,
    };

    final infoList = <_ThreadInfo>[
      if (replyCount != null) (Icons.forum_outlined, '$replyCount'),
      if (viewCount != null) (Icons.bar_chart_outlined, '$viewCount'),
      if (showLastReplyAuthor && lastReplyAuthor != null) (Icons.person_outline, lastReplyAuthor!.name),
      if (latestReplyTime != null) (Icons.timelapse_outlined, latestReplyTime!.elapsedTillNow(context)),
      if ((price ?? 0) > 0) (FontAwesomeIcons.coins, '$price'),
      if ((privilege ?? 0) > 0) (Icons.feedback_outlined, '$privilege'),
    ];

    if (infoList.isEmpty) {
      return sizedBoxEmpty;
    }

    if (infoRowAlignCenter) {
      // In center.
      return Padding(
        padding: edgeInsetsL16R16B12,
        child: Row(
          children: [
            Expanded(
              child: Row(
                children:
                    infoList
                        .map(
                          (e) => Expanded(
                            child: Row(
                              children: [
                                Icon(e.$1, size: smallIconSize, color: infoColor),
                                sizedBoxW4H4,
                                Expanded(
                                  child: Text(
                                    e.$2,
                                    style: TextStyle(fontSize: smallTextSize, color: infoColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      );
    } else {
      // Not in center.
      return Padding(
        padding: edgeInsetsL16R16B12,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                infoList
                    .map(
                      (e) => [
                        Icon(e.$1, size: smallIconSize, color: infoColor),
                        sizedBoxW4H4,
                        Text(e.$2, style: TextStyle(fontSize: smallTextSize, color: infoColor), maxLines: 1),
                        sizedBoxW12H12,
                      ],
                    )
                    .flattened
                    .toList(),
          ),
        ),
      );
    }
  }

  Widget _buildCardTitle(BuildContext context, SettingsState state) {
    final highlightRecentThread = state.settingsMap.threadCardHighlightRecentThread;
    final TextStyle? authorNameStyle;
    if (state.settingsMap.threadCardHighlightAuthorName) {
      authorNameStyle = TextStyle(color: Theme.of(context).colorScheme.primary);
    } else {
      authorNameStyle = null;
    }

    final TextStyle? timeStyle;
    if (isRecentThread && highlightRecentThread) {
      timeStyle = TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontSize: Theme.of(context).textTheme.labelMedium?.fontSize,
      );
    } else {
      timeStyle = TextStyle(fontSize: Theme.of(context).textTheme.labelMedium?.fontSize);
    }

    final forumNameStyle = TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: Theme.of(context).textTheme.labelMedium?.fontSize,
    );

    if (author != null) {
      return ListTile(
        leading: GestureDetector(
          onTap: disableTap ? null : () async => context.dispatchAsUrl(author!.url),
          child: _buildAvatar(context),
        ),
        title: Row(
          children: [
            GestureDetector(
              onTap: disableTap ? null : () async => context.dispatchAsUrl(author!.url),
              child: SingleLineText(author!.name, style: authorNameStyle),
            ),
            const Spacer(),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (publishTime != null) SingleLineText(publishTime!.yyyyMMDD(), style: timeStyle),
            if (forum != null) SingleLineText(forum!, style: forumNameStyle),
          ],
        ),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (stateSet != null) ...stateSet!.map((e) => Icon(e.icon, size: 16)),
            Text(threadType?.name ?? ''),
          ].insertBetween(sizedBoxW4H4),
        ),
      );
    }

    return ListTile(
      leading: Chip(label: Text(context.t.myThreadPage.forum)),
      title: Text('$forum', style: authorNameStyle),
      subtitle: publishTime != null ? SingleLineText(publishTime!.yyyyMMDD(), style: timeStyle) : null,
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (stateSet != null) ...stateSet!.map((e) => Icon(e.icon, size: 16)),
          Text(threadType?.name ?? ''),
        ].insertBetween(sizedBoxW4H4),
      ),
    );
  }

  /// Build a thread card that has [author] (or [forum] when [author] is null)
  /// info like title, thread title or
  /// content as body, and thread info as bottom.
  Widget _buildContent(BuildContext context, SettingsState state) {
    final infoRowAlignCenter = state.settingsMap.threadCardInfoRowAlignCenter;
    final showLastReplyAuthor = state.settingsMap.threadCardShowLastReplyAuthor;
    final highlightInfoRow = state.settingsMap.threadCardHighlightInfoRow;

    return _wrapWithCard(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Tap to navigate to user space.
          _buildCardTitle(context, state),
          Padding(
            padding: edgeInsetsL16R16B12,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: css?.color, fontWeight: css?.fontWeight),
                  ),
                ),
              ],
            ),
          ),
          if (quotedMessage != null)
            Padding(
              padding: edgeInsetsL16R16B12,
              child: Row(children: [Expanded(child: QuotedText(quotedMessage ?? ''))]),
            ),
          _buildInfoWidgetRow(
            context: context,
            infoRowAlignCenter: infoRowAlignCenter,
            showLastReplyAuthor: showLastReplyAuthor,
            highlightInfoRow: highlightInfoRow,
          ),
        ].insertBetween(sizedBoxW12H12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (prev, curr) {
        final pm = prev.settingsMap;
        final cm = curr.settingsMap;

        return pm.threadCardInfoRowAlignCenter != cm.threadCardInfoRowAlignCenter ||
            pm.threadCardShowLastReplyAuthor != cm.threadCardShowLastReplyAuthor ||
            pm.threadCardHighlightRecentThread != cm.threadCardHighlightRecentThread ||
            pm.threadCardHighlightAuthorName != cm.threadCardHighlightAuthorName ||
            pm.threadCardHighlightInfoRow != cm.threadCardHighlightInfoRow;
      },
      builder: _buildContent,
    );
  }
}

/// Card to show thread info.
class NormalThreadCard extends StatelessWidget {
  /// Constructor.
  const NormalThreadCard(this.thread, {this.disableTap = false, super.key});

  /// Thread data.
  final NormalThread thread;

  /// Creat a card that disable tap gestures.
  final bool disableTap;

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
      lastReplyAuthor: thread.latestReplyAuthor,
      latestReplyTime: thread.latestReplyTime,
      price: thread.price,
      privilege: thread.privilege,
      css: thread.css,
      stateSet: thread.stateSet,
      disableTap: disableTap,
      isRecentThread: thread.isRecentThread,
    );
  }
}

/// Card to show a thread in search result.
class SearchedThreadCard extends StatelessWidget {
  /// Constructor.
  const SearchedThreadCard(this.thread, {super.key});

  /// Thread model.
  final SearchedThread thread;

  @override
  Widget build(BuildContext context) {
    return _CardLayout(
      threadID: '${thread.threadID}',
      title: thread.title,
      forum: thread.forumName,
      author: thread.author,
      publishTime: thread.publishTime,
    );
  }
}

/// Card to show current user's thread info in "My Thread" page.
class MyThreadCard extends StatelessWidget {
  /// Constructor.
  const MyThreadCard(this.thread, {super.key});

  /// Thread model.
  final MyThread thread;

  @override
  Widget build(BuildContext context) {
    return _CardLayout(
      threadID: thread.threadID,
      title: thread.title,
      forum: thread.forumName,
      stateSet: thread.stateSet,
      publishTime: thread.latestReplyTime,
      quotedMessage: thread.quotedMessage,
      lastReplyAuthor: thread.latestReplyAuthor,
      latestReplyTime: thread.latestReplyTime,
      replyCount: thread.replyCount,
      viewCount: thread.viewCount,
    );
  }
}

/// Card to show result in "Latest thread" page.
class LatestThreadCard extends StatelessWidget {
  /// Constructor.
  const LatestThreadCard(this.thread, {super.key});

  /// Thread model.
  final LatestThread thread;

  @override
  Widget build(BuildContext context) {
    return _CardLayout(
      threadID: thread.threadID!,
      title: thread.title!,
      author: thread.latestReplyAuthor,
      // FIXME: Do not use thread type to represent forum.
      threadType: ThreadType(name: thread.forumName!, url: thread.forumUrl!),
      publishTime: thread.latestReplyTime,
      quotedMessage: thread.quotedMessage,
    );
  }
}
