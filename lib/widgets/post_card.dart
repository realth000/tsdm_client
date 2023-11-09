import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/models/post.dart';
import 'package:tsdm_client/packages/html_muncher/lib/html_muncher.dart';
import 'package:tsdm_client/widgets/cached_image_provider.dart';
import 'package:universal_html/parsing.dart';

/// Card for a [Post] model.
///
/// Usually inside a ThreadPage.
class PostCard extends ConsumerWidget {
  /// Constructor.
  const PostCard(this.post, {super.key});

  /// [Post] model to show.
  final Post post;

  // TODO: Handle better.
  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedImageProvider(
                post.author.avatarUrl!,
                context,
                ref,
                fallbackImageUrl: noAvatarUrl,
              ),
            ),
            title: Text(post.author.name),
            subtitle: Text('${post.publishTime?.elapsedTillNow()}'),
            trailing:
                post.postFloor == null ? null : Text('#${post.postFloor}'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: munchElement(context, parseHtmlDocument(post.data).body!),
          ),
        ],
      );
}
