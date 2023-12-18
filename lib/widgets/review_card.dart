import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/cached_image_provider.dart';

class ReviewCard extends ConsumerWidget {
  const ReviewCard({
    required this.name,
    required this.content,
    this.avatarUrl,
    super.key,
  });

  final String? avatarUrl;
  final String name;
  final String content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(context.t.reviewCard.title,
            style: Theme.of(context).textTheme.titleMedium),
        ListTile(
          leading: CircleAvatar(
              backgroundImage: CachedImageProvider(
            avatarUrl ?? noAvatarUrl,
            context,
            ref,
          )),
          title: Text(name),
          subtitle: Text(content, maxLines: 3),
        ),
      ],
    );
  }
}
