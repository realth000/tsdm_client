import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/models/post.dart';
import 'package:tsdm_client/models/user.dart';
import 'package:tsdm_client/packages/html_muncher/lib/html_muncher.dart';
import 'package:tsdm_client/widgets/cached_image_provider.dart';
import 'package:tsdm_client/widgets/locked_card.dart';
import 'package:tsdm_client/widgets/rate_card.dart';
import 'package:universal_html/parsing.dart';

/// Card for a [Post] model.
///
/// Usually inside a ThreadPage.
class PostCard extends ConsumerStatefulWidget {
  /// Constructor.
  const PostCard(this.post, {this.replyCallback, super.key});

  /// [Post] model to show.
  final Post post;

  final FutureOr<void> Function(User user, int? postFloor, String? replyAction)?
      replyCallback;

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with AutomaticKeepAliveClientMixin {
  // TODO: Handle better.
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedImageProvider(
              widget.post.author.avatarUrl!,
              context,
              ref,
              fallbackImageUrl: noAvatarUrl,
            ),
          ),
          title: Text(widget.post.author.name),
          subtitle: Text('${widget.post.publishTime?.elapsedTillNow()}'),
          trailing: widget.post.postFloor == null
              ? null
              : Text('#${widget.post.postFloor}'),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            await widget.replyCallback?.call(widget.post.author,
                widget.post.postFloor, widget.post.replyAction);
          },
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: edgeInsetsL15R15B10,
                  child: munchElement(
                      context, parseHtmlDocument(widget.post.data).body!),
                ),
              ),
            ],
          ),
        ),
        if (widget.post.locked.isNotEmpty)
          ...widget.post.locked.where((e) => e.isValid()).map(LockedCard.new),
        if (widget.post.rate != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 712),
            child: RateCard(widget.post.rate!),
          ),
      ],
    );
  }

  // Add mixin and return true to avoid post list shaking when scrolling.
  @override
  bool get wantKeepAlive => true;
}
