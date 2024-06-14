import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';

////////////////////////////////////////////////////////////////////////
///
/// All widgets in this file are add functionality on [Hero] animation.
///
////////////////////////////////////////////////////////////////////////

/// Like [CircleAvatar], display user avatar but with hero animation support.
final class HeroUserAvatar extends StatelessWidget {
  /// Constructor.
  const HeroUserAvatar({
    required this.username,
    required this.avatarUrl,
    this.heroTag,
    this.maxRadius,
    this.minRadius,
    super.key,
  });

  /// Optional override of the tag used in [Hero].
  final String? heroTag;

  /// Username
  final String username;

  /// User avatar
  final String? avatarUrl;

  /// Max avatar border radius.
  final double? minRadius;

  /// Min avatar border radius.
  final double? maxRadius;

  @override
  Widget build(BuildContext context) {
    final Widget avatar;
    if (avatarUrl == null) {
      avatar = CircleAvatar(
        maxRadius: maxRadius,
        minRadius: minRadius,
        child: Text(username.isEmpty ? '' : username[0]),
      );
    } else {
      avatar = CircleAvatar(
        backgroundImage: CachedImageProvider(
          avatarUrl!,
          context,
          fallbackImageUrl: noAvatarUrl,
        ),
        maxRadius: maxRadius,
        minRadius: minRadius,
      );
    }
    return Hero(tag: heroTag ?? 'UserAvatar_$username', child: avatar);
  }
}
