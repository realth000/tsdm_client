import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/features/thread/bloc/thread_bloc.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
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
  final FutureOr<void> Function(User user, int? postFloor, String? replyAction)?
      replyCallback;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with AutomaticKeepAliveClientMixin {
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

  // TODO: Handle better.
  // FIXME: Fix rebuild when interacting with widgets inside.
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final threadBloc = context.readOrNull<ThreadBloc>();
    final onlyVisibleUid = threadBloc?.state.onlyVisibleUid;
    final avatarHeroTag =
        'Avatar-${widget.post.author.uid}-${widget.post.postFloor}';
    final nameHeroTag =
        'Name-${widget.post.author.name}-${widget.post.postFloor}';

    return Padding(
      padding: edgeInsetsL12R12B12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post author user info.
          ListTile(
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
                    flightShuttleBuilder: (_, __, ___, ____, toHeroContext) =>
                        DefaultTextStyle(
                      style: DefaultTextStyle.of(toHeroContext).style,
                      child: toHeroContext.widget,
                    ),
                    child: Text(widget.post.author.name),
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
            subtitle: Text('${widget.post.publishTime?.elapsedTillNow()}'),
            trailing: widget.post.postFloor == null
                ? null
                : Text('#${widget.post.postFloor}'),
          ),
          // Last edit status.
          if (widget.post.lastEditUsername != null &&
              widget.post.lastEditTime != null)
            Padding(
              padding: edgeInsetsL12T4R12,
              child: Text(
                context.t.postCard.lastEditInfo(
                  username: widget.post.lastEditUsername!,
                  time: widget.post.lastEditTime!,
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
          // Post body
          sizedBoxW12H12,
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              await widget.replyCallback?.call(
                widget.post.author,
                widget.post.postFloor,
                widget.post.replyAction,
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: edgeInsetsL16R16,
                    child: munchElement(
                      context,
                      parseHtmlDocument(widget.post.data).body!,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 红包 if any.
          if (widget.post.locked.isNotEmpty)
            ...widget.post.locked.where((e) => e.isValid()).map(LockedCard.new),
          if (widget.post.packetUrl != null) ...[
            sizedBoxW12H12,
            PacketCard(widget.post.packetUrl!),
          ],
          // Rate status if any.
          if (widget.post.rate != null) ...[
            sizedBoxW12H12,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 712),
              child: RateCard(widget.post.rate!),
            ),
          ],
          // Context menu.
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton(
                itemBuilder: (context) => [
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
                  if (threadBloc != null &&
                      onlyVisibleUid == null &&
                      widget.post.author.uid != null)
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
                      await widget.replyCallback?.call(
                        widget.post.author,
                        widget.post.postFloor,
                        widget.post.replyAction,
                      );
                    case _PostCardActions.rate:
                      if (widget.post.rateAction != null) {
                        await _rateCallback.call();
                      }
                    case _PostCardActions.viewTheAuthor:
                      // Here is guaranteed a not-null `ThreadBloc`.
                      context.read<ThreadBloc>().add(
                            ThreadOnlyViewAuthorRequested(
                              widget.post.author.uid!,
                            ),
                          );
                    case _PostCardActions.viewAllAuthors:
                      // Here is guaranteed a not-null `ThreadBloc` and a
                      // not-null author uid.
                      context
                          .read<ThreadBloc>()
                          .add(ThreadViewAllAuthorsRequested());
                    case _PostCardActions.edit:
                      await context.dispatchAsUrl(widget.post.editUrl!);
                    case _PostCardActions.share:
                      await copyToClipboard(context, widget.post.shareLink!);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Add mixin and return true to avoid post list shaking when scrolling.
  @override
  bool get wantKeepAlive => true;
}
