part of 'models.dart';

/// Image cache status.
///
/// Add "2" to avoid name conflict with flutter/painting/ImageCacheStatus.
enum ImageCacheStatus2 {
  /// Image has no cache and no caching process is running.
  notCached,

  /// Image is in caching process.
  loading,

  /// Image is successfully cached.
  cached,
}

/// All types of image cached response, corresponding to
/// `ImageCacheGeneralRequest`.
enum ImageCacheResponseType {
  /// General purpose.
  general,

  /// User avatar.
  userAvatar,
}

/// Response of image cache request.
///
/// Each instance contains an event related to a image specified with its url.
/// Represents:
///
/// * Image cached success and here is its data.
/// * Image loaded from cache success and here is its data.
/// * Image cached failed.
/// * Image is caching.
///
/// This model is made as communicate messages between the global image cache
/// manager and widgets using images.
///
/// Actually this is a "event" triggered from image cache repository that sent
/// to listeners, but name it as "response" to distinguish with bloc events.
@MappableClass()
sealed class ImageCacheResponse with ImageCacheResponseMappable {
  /// Constructor.
  const ImageCacheResponse(this.imageId, this.respType);

  /// Image's unique id.
  ///
  /// Identify the image cached for.
  ///
  /// Usually us the image's url as id.
  final String imageId;

  /// Response type.
  final ImageCacheResponseType respType;
}

/// Represents successfully cached a data.
///
/// Data maybe directly loaded from cache, or downloaded from image url.
@MappableClass()
final class ImageCacheSuccessResponse extends ImageCacheResponse
    with ImageCacheSuccessResponseMappable {
  /// Constructor.
  const ImageCacheSuccessResponse(
    super.imageId,
    super.respType,
    this.imageData,
  );

  /// Binary image data.
  final Uint8List imageData;
}

/// Represents the image is loading.
///
/// Images in this state do not have a valid cache and is loading from the
/// given image url.
@MappableClass()
final class ImageCacheLoadingResponse extends ImageCacheResponse
    with ImageCacheLoadingResponseMappable {
  /// Constructor.
  const ImageCacheLoadingResponse(super.imageId, super.respType);
}

/// Represents failed to cache image.
///
/// Images in this state do not have a valid cache, and no loading requests.
///
/// Ready for another retry.
@MappableClass()
final class ImageCacheFailedResponse extends ImageCacheResponse
    with ImageCacheFailedResponseMappable {
  /// Constructor.
  const ImageCacheFailedResponse(super.imageId, super.respType);
}

/// A reply to a new state.
///
/// This model is made because we want to tell the presentation layer the latest
/// status of a given image.
///
/// Use [ImageCacheStatus2] to tell image cache status.
@MappableClass()
final class ImageCacheStatusResponse extends ImageCacheResponse
    with ImageCacheStatusResponseMappable {
  /// Constructor.
  const ImageCacheStatusResponse(
    super.imageId,
    super.respType,
    this.status,
    this.imageData,
  );

  /// Status of cache.
  final ImageCacheStatus2 status;

  /// Binary image data.
  ///
  /// Only not null when we have the data (actually nonsense).
  final Uint8List? imageData;
}
