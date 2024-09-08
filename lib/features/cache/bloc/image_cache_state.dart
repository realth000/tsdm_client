part of 'image_cache_bloc.dart';

/// Basic state class
@MappableClass()
sealed class ImageCacheState with ImageCacheStateMappable {
  /// Constructor.
  const ImageCacheState();
}

/// Loading data.
@MappableClass()
final class ImageCacheInitial extends ImageCacheState
    with ImageCacheInitialMappable {
  /// Constructor.
  const ImageCacheInitial();
}

/// Loading data.
@MappableClass()
final class ImageCacheLoading extends ImageCacheState
    with ImageCacheLoadingMappable {
  /// Constructor.
  const ImageCacheLoading();
}

/// Successfully loaded cache.
@MappableClass()
final class ImageCacheSuccess extends ImageCacheState
    with ImageCacheSuccessMappable {
  /// Constructor.
  const ImageCacheSuccess(this.imageData);

  /// Image data.
  final Uint8List imageData;
}

/// Failed to load cache.
@MappableClass()
final class ImageCacheFailure extends ImageCacheState
    with ImageCacheFailureMappable {
  /// Constructor.
  const ImageCacheFailure();
}
