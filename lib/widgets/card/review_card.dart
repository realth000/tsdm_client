import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';

/// Widget to show a review for a post.
class ReviewCard extends StatelessWidget {
  /// Constructor.
  const ReviewCard({
    required this.name,
    required this.content,
    this.avatarUrl,
    super.key,
  });

  /// Reviewer avatar url.
  final String? avatarUrl;

  /// Reviewer name.
  final String name;

  /// Review content.
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(
          context.t.reviewCard.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedImageProvider(
              avatarUrl ?? noAvatarUrl,
              fallbackImageUrl: noAvatarUrl,
              usage: ImageUsageInfoUserAvatar(name),
            ),
          ),
          title: Text(name),
          subtitle: Text(content, maxLines: 3),
        ),
      ],
    );
  }
}
