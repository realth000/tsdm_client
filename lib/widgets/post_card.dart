import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/post.dart';

/// Card for a [Post] model.
///
/// Usually inside a [ThreadPage].
class PostCard extends ConsumerWidget {
  /// Constructor.
  const PostCard(this.post, {super.key});

  /// [Post] model to show.
  final Post post;

  // TODO: Handle better.
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
        child: Column(
          children: [
            ListTile(
              leading: Image.network(post.author.avatarUrl!),
              title: Text(post.author.name),
              subtitle: Text('uid ${post.author.uid ?? ""}'),
            ),
            HtmlWidget(post.data),
          ],
        ),
      );
}
