import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tsdm_client/features/cache/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/models/models.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';

////////////////////////////////////////////////////////////////////////
///
/// All widgets in this file are add functionality on [Hero] animation.
///
////////////////////////////////////////////////////////////////////////

/// Like [CircleAvatar], display user avatar but with hero animation support.
final class HeroUserAvatar extends StatefulWidget {
  // Can no be a const constructor.
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

  /// Has data
  ///
  /// This flag is a flag that can ONLY be set once.
  /// Because [hasError] may change during `setState` triggered from other part
  /// of the widget tree and the loaded data is reserved during all `setState`,
  /// The state may be incorrectly considered as "has error, has no image data"
  /// when effected by `setState`.
  ///
  /// Use this flag to indicate that the image is already cached and should not
  /// be considered as broken state, which prevents showing the fallback first
  /// letter.
  bool _dataLoaded = false;

  StreamSubscription<ImageCacheResponse>? imageCacheSub;

  Future<void> onImageCachedResponse(ImageCacheResponse resp) async {
    if (!mounted) {
      return;
    }

    switch (resp) {
      case ImageCacheSuccessResponse():
        // Now the image is cached, load image data.
        if (hasError) {
          setState(() {
            hasError = false;
          });
        }
        if (!_dataLoaded) {
          setState(() => _dataLoaded = true);
        }
        await widget._imageProvider.evict();
      case ImageCacheLoadingResponse() ||
            ImageCacheStatusResponse(status: ImageCacheStatus2.loading):
        if (hasError) {
          setState(() => hasError = false);
        }
      case ImageCacheFailedResponse() ||
            ImageCacheStatusResponse(status: ImageCacheStatus2.notCached):
        if (!hasError) {
          setState(() {
            hasError = true;
            _dataLoaded = false;
          });
        }
      case ImageCacheStatusResponse(status: ImageCacheStatus2.cached):
        // Now the image is cached, load image data.
        if (hasError) {
          setState(() {
            hasError = false;
          });
          if (!_dataLoaded) {
            setState(() => _dataLoaded = true);
          }
        } else {
          setState(() => _dataLoaded = false);
        }
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
    getIt.get<ImageCacheProvider>().queryCacheState(
          ImageCacheUserAvatarRequest(
            username: widget.username,
            imageUrl: widget.avatarUrl ?? '',
          ),
        );
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
      child: hasError & !_dataLoaded
          ? Text(widget.username.isEmpty ? ' ' : widget.username[0])
          : null,
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

/// Show a dialog with hero animation support.
///
/// The dialog content is built by the parameter [builder].
Future<T?> showHeroDialog<T>(
  BuildContext context,
  RoutePageBuilder builder,
) async {
  return Navigator.push<T>(
    context,
    PageRouteBuilder(
      opaque: false,
      // Fix barrier color.
      // ref: flutter/lib/src/material/dialog.dart: showDialog()
      barrierColor:
          Theme.of(context).dialogTheme.barrierColor ?? Colors.black54,
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) =>
          builder(context, animation, secondaryAnimation),
      // fullscreenDialog: true,
      transitionsBuilder: (context, ani1, ani2, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeIn).animate(ani1),
          child: child,
        );
      },
    ),
  );
}
