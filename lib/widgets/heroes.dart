import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tsdm_client/features/cache/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';

////////////////////////////////////////////////////////////////////////
///
/// All widgets in this file are add functionality on [Hero] animation.
///
////////////////////////////////////////////////////////////////////////

/// Like [CircleAvatar], display user avatar but with hero animation support.
final class HeroUserAvatar extends StatefulWidget {
  // ignore: prefer_const_constructor_declarations
  /// Constructor.
  HeroUserAvatar({
    required this.username,
    required this.avatarUrl,
    this.heroTag,
    this.maxRadius,
    this.minRadius,
    this.disableHero = false,
    super.key,
  }) {
    _imageProvider = CachedImageProvider(
      // FIXME: Fix nullable arg.
      avatarUrl ?? '',
      usage: ImageUsageInfoUserAvatar(username),
    );
  }

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

  late final CachedImageProvider _imageProvider;

  @override
  State<HeroUserAvatar> createState() => _HeroUserAvatarState();
}

class _HeroUserAvatarState extends State<HeroUserAvatar> {
  bool hasError = false;

  StreamSubscription<ImageCacheResponse>? imageCacheSub;

  Future<void> onImageCachedResponse(ImageCacheResponse resp) async {
    if (!mounted) {
      return;
    }

    switch (resp) {
      case ImageCacheSuccessResponse():
        await widget._imageProvider.evict();
      case ImageCacheLoadingResponse() ||
            ImageCacheStatusResponse(status: ImageCacheStatus2.loading):
        if (hasError) {
          setState(() => hasError = false);
        }
      case ImageCacheFailedResponse() ||
            ImageCacheStatusResponse(status: ImageCacheStatus2.notCached):
        if (!hasError) {
          setState(() => hasError = true);
        }
      case ImageCacheStatusResponse(status: ImageCacheStatus2.cached):
        await widget._imageProvider.evict();
    }
  }

  @override
  void initState() {
    super.initState();
    imageCacheSub = getIt
        .get<ImageCacheProvider>()
        .response
        .where(
          (e) =>
              e.respType == ImageCacheResponseType.userAvatar &&
              e.imageId == widget.username,
        )
        .listen((resp) async => onImageCachedResponse(resp));
  }

  @override
  void dispose() {
    imageCacheSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget avatar;
    avatar = CircleAvatar(
      backgroundImage: widget._imageProvider,
      maxRadius: widget.maxRadius,
      minRadius: widget.minRadius,
      child: hasError
          ? Text(widget.username.isEmpty ? ' ' : widget.username[0])
          : null,
      onBackgroundImageError: (_, __) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              hasError = true;
            });
          });
        }
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
