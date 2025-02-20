import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/features/post/models/models.dart';
import 'package:tsdm_client/features/thread/v1/bloc/thread_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/clipboard.dart';
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:tsdm_client/widgets/card/lock_card/locked_card.dart';
import 'package:tsdm_client/widgets/card/packet_card.dart';
import 'package:tsdm_client/widgets/card/post_card/show_user_brief_profile_dialog.dart';
import 'package:tsdm_client/widgets/card/rate_card.dart';
import 'package:tsdm_client/widgets/heroes.dart';
import 'package:universal_html/parsing.dart';

/// Actions in post context menu.
///
/// * State of [viewTheAuthor] and [viewAllAuthors] are thread level state so
///   this state is stored by the parent thread. Disable these actions when
///   there is no available thread above current post in the widget tree.
enum _PostCardActions {
  reply,
  rate,

  /// Only view posts published by current author.
  viewTheAuthor,

  /// View all authors.
  viewAllAuthors,

  /// Edit the post.
  ///
  /// Only available when the current user is the author of post.
  edit,

  /// Share the post.
  ///
  /// Share with thread and post id, and 'fromuid=$UID'.
  share,
}

/// Card for a [Post] model.
///
/// Usually inside a ThreadPage.
class PostCard extends StatefulWidget {
  /// Constructor.
  const PostCard(this.post, {this.replyCallback, super.key});

  /// [Post] model to show.
  final Post post;

  /// A callback function that will be called every time when user try to
  /// reply to the post.
  final FutureOr<void> Function(User user, int? postFloor, String? replyAction)? replyCallback;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with AutomaticKeepAliveClientMixin {
  Future<void> _rateCallback() async {
    await context.pushNamed(
      ScreenPaths.ratePost,
      pathParameters: <String, String>{
        'username': widget.post.author.name,
        'pid': widget.post.postID,
        'floor': '${widget.post.postFloor}',
        'rateAction': widget.post.rateAction!,
      },
    );
  }

  Widget _buildAuthorRow(BuildContext context) {
    final avatarHeroTag = 'Avatar-${widget.post.author.uid}-${widget.post.postFloor}';
    final nameHeroTag = 'Name-${widget.post.author.name}-${widget.post.postFloor}';

    return ListTile(
      leading: GestureDetector(
        onTap: () async {
          if (widget.post.userBriefProfile != null) {
            await showUserBriefProfileDialog(
              context,
              widget.post.userBriefProfile!,
              widget.post.author.url,
              avatarHeroTag: avatarHeroTag,
              nameHeroTag: nameHeroTag,
            );
          }
        },
        child: HeroUserAvatar(
          avatarUrl: widget.post.author.avatarUrl,
          username: widget.post.author.name,
          heroTag: avatarHeroTag,
        ),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () async {
              if (widget.post.userBriefProfile != null) {
                await showUserBriefProfileDialog(
                  context,
                  widget.post.userBriefProfile!,
                  widget.post.author.url,
                  avatarHeroTag: avatarHeroTag,
                  nameHeroTag: nameHeroTag,
                );
              }
            },
            child: Hero(
              tag: nameHeroTag,
              flightShuttleBuilder:
                  (_, __, ___, ____, toHeroContext) =>
                      DefaultTextStyle(style: DefaultTextStyle.of(toHeroContext).style, child: toHeroContext.widget),
              child: Text(widget.post.author.name, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ),
          sizedBoxW4H4,
          if (widget.post.userBriefProfile?.nickname != null)
            Text(
              widget.post.userBriefProfile!.nickname!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
              maxLines: 1,
            ),
          const Spacer(),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post.userBriefProfile?.userGroup ?? '',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          sizedBoxW4H4,
          Text(
            '${widget.post.publishTime?.yyyyMMDDHHMMSS()}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [if (widget.post.postFloor == null) const Text('#') else Text('#${widget.post.postFloor}')],
      ),
    );
  }

  Widget _buildLastEditInfoRow(BuildContext context) {
    return Padding(
      padding: edgeInsetsL12T4R12,
      child: Text(
        context.t.postCard.lastEditInfo(username: widget.post.lastEditUsername!, time: widget.post.lastEditTime!),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
      ),
    );
  }

  Widget _buildPostBody(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await widget.replyCallback?.call(widget.post.author, widget.post.postFloor, widget.post.replyAction);
      },
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: edgeInsetsL16R16,
              child: munchElement(context, parseHtmlDocument(widget.post.data).body!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextMenu(BuildContext context) {
    final threadBloc = context.readOrNull<ThreadBloc>();
    final onlyVisibleUid = threadBloc?.state.onlyVisibleUid;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PopupMenuButton(
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: _PostCardActions.reply,
                  child: Row(
                    children: [
                      const Icon(Icons.reply_outlined),
                      sizedBoxPopupMenuItemIconSpacing,
                      Text(context.t.postCard.reply),
                    ],
                  ),
                ),
                if (widget.post.rateAction != null)
                  PopupMenuItem(
                    value: _PostCardActions.rate,
                    child: Row(
                      children: [
                        const Icon(Icons.rate_review_outlined),
                        sizedBoxPopupMenuItemIconSpacing,
                        Text(context.t.postCard.rate),
                      ],
                    ),
                  ),

                /// Viewing all authors, can switch to only view current
                /// author mode.
                if (threadBloc != null && onlyVisibleUid == null && widget.post.author.uid != null)
                  PopupMenuItem(
                    value: _PostCardActions.viewTheAuthor,
                    child: Row(
                      children: [
                        const Icon(Icons.person_outlined),
                        sizedBoxPopupMenuItemIconSpacing,
                        Text(context.t.postCard.onlyViewAuthor),
                      ],
                    ),
                  ),

                /// Viewing specified author now, can switch to view all
                /// authors mode.
                if (threadBloc != null && onlyVisibleUid != null)
                  PopupMenuItem(
                    value: _PostCardActions.viewAllAuthors,
                    child: Row(
                      children: [
                        const Icon(Icons.group_outlined),
                        sizedBoxPopupMenuItemIconSpacing,
                        Text(context.t.postCard.viewAllAuthors),
                      ],
                    ),
                  ),
                if (widget.post.editUrl != null)
                  PopupMenuItem(
                    value: _PostCardActions.edit,
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined),
                        sizedBoxPopupMenuItemIconSpacing,
                        Text(context.t.postCard.edit),
                      ],
                    ),
                  ),
                if (widget.post.shareLink != null)
                  PopupMenuItem(
                    value: _PostCardActions.share,
                    child: Row(
                      children: [
                        const Icon(Icons.share_outlined),
                        sizedBoxPopupMenuItemIconSpacing,
                        Text(context.t.postCard.share),
                      ],
                    ),
                  ),
              ],
          onSelected: (value) async {
            switch (value) {
              case _PostCardActions.reply:
                await widget.replyCallback?.call(widget.post.author, widget.post.postFloor, widget.post.replyAction);
              case _PostCardActions.rate:
                if (widget.post.rateAction != null) {
                  await _rateCallback.call();
                }
              case _PostCardActions.viewTheAuthor:
                // Here is guaranteed a not-null `ThreadBloc`.
                context.read<ThreadBloc>().add(ThreadOnlyViewAuthorRequested(widget.post.author.uid!));
              case _PostCardActions.viewAllAuthors:
                // Here is guaranteed a not-null `ThreadBloc` and a
                // not-null author uid.
                context.read<ThreadBloc>().add(ThreadViewAllAuthorsRequested());
              case _PostCardActions.edit:
                final url = Uri.parse(widget.post.editUrl!);
                final editType = widget.post.isDraft ? PostEditType.editDraft.index : PostEditType.editPost.index;
                await context.pushNamed(
                  ScreenPaths.editPost,
                  pathParameters: {'editType': '$editType', 'fid': '${url.queryParameters["fid"]}'},
                  queryParameters: {'tid': '${url.queryParameters["tid"]}', 'pid': '${url.queryParameters["pid"]}'},
                );
              case _PostCardActions.share:
                await copyToClipboard(context, widget.post.shareLink!);
            }
          },
        ),
      ],
    );
  }

  // TODO: Handle better.
  // FIXME: Fix rebuild when interacting with widgets inside.
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post author user info.
        _buildAuthorRow(context),
        // Last edit status.
        if (widget.post.lastEditUsername != null && widget.post.lastEditTime != null) _buildLastEditInfoRow(context),
        // Post body
        sizedBoxW12H12,
        _buildPostBody(context),
        // 红包 if any.
        if (widget.post.locked.isNotEmpty) ...widget.post.locked.where((e) => e.isValid()).map(LockedCard.new),
        if (widget.post.packetUrl != null) ...[
          sizedBoxW12H12,
          PacketCard(widget.post.packetUrl!, allTaken: widget.post.packetAllTaken),
        ],
        // Rate status if any.
        if (widget.post.rate != null) ...[
          sizedBoxW12H12,
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 712), child: RateCard(widget.post.rate!)),
        ],
        // Context menu.
        _buildContextMenu(context),
      ],
    );
  }

  // Add mixin and return true to avoid post list shaking when scrolling.
  @override
  bool get wantKeepAlive => true;
}
