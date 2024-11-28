import 'package:flutter/material.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';

////////////////////////////////////////////////////////////////////////
///
/// All widgets in this file are add functionality on [Hero] animation.
///
////////////////////////////////////////////////////////////////////////

/// Like [CircleAvatar], display user avatar but with hero animation support.
final class HeroUserAvatar extends StatefulWidget {
  /// Constructor.
  const HeroUserAvatar({
    required this.username,
    required this.avatarUrl,
    this.heroTag,
    this.maxRadius,
    this.minRadius,
    this.disableHero = false,
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

  /// Disable hero animation.
  ///
  /// Use in absolutely multi-hero-tag pages.
  final bool disableHero;

  @override
  State<HeroUserAvatar> createState() => _HeroUserAvatarState();
}

class _HeroUserAvatarState extends State<HeroUserAvatar> {
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    final Widget avatar;
    avatar = CircleAvatar(
      backgroundImage: CachedImageProvider(
        // FIXME: Fix nullable arg.
        widget.avatarUrl ?? '',
        context,
        usage: ImageUsageInfoUserAvatar(widget.username),
      ),
      maxRadius: widget.maxRadius,
      minRadius: widget.minRadius,
      child: hasError
          ? Text(widget.username.isEmpty ? ' ' : widget.username[0])
          : null,
      onBackgroundImageError: (_, __) {
        setState(() {
          hasError = true;
        });
      },
    );
    if (widget.disableHero) {
      return avatar;
    }
    return Hero(
      tag: widget.heroTag ?? 'UserAvatar_${widget.username}',
      flightShuttleBuilder: (_, __, ___, ____, toHeroContext) =>
          DefaultTextStyle(
        style: DefaultTextStyle.of(toHeroContext).style,
        child: toHeroContext.widget,
      ),
      child: avatar,
    );
  }
}
