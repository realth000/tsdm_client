part of 'image_cache_bloc.dart';

/// Basic event of [ImageCacheBloc].
sealed class ImageCacheEvent extends Equatable {
  /// Constructor.
  const ImageCacheEvent();

  @override
  List<Object> get props => [];
}

/// User requested to load the image
final class ImageCacheLoadRequested extends ImageCacheEvent {
  /// Constructor.
  const ImageCacheLoadRequested({this.force = false});

  /// Force load image from url, not cache.
  final bool force;

  @override
  List<Object> get props => [force];
}

/// Successfully loaded image cache.
///
/// Internal event.
final class _ImageCacheLoadSuccess extends ImageCacheEvent {
  /// Constructor.
  const _ImageCacheLoadSuccess(this.imageData);

  // Binary image data.
  final Uint8List imageData;

  @override
  List<Object> get props => [imageData];
}

/// Pending image cache.
///
/// Internal event.
final class _ImageCacheLoadPending extends ImageCacheEvent {
  /// Constructor.
  const _ImageCacheLoadPending();

  @override
  List<Object> get props => [];
}

/// Failed to load image cache.
///
/// Internal event.
final class _ImageCacheLoadFailed extends ImageCacheEvent {
  /// Constructor.
  const _ImageCacheLoadFailed();

  @override
  List<Object> get props => [];
}
