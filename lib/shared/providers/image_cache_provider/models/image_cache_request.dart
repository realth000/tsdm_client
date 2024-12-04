part of 'models.dart';

/// All kinds of image cached requests sent to cached image provider.
@MappableClass()
sealed class ImageCacheRequest with ImageCacheRequestMappable {
  /// Constructor.
  const ImageCacheRequest(this.imageUrl);

  /// Image url
  final String imageUrl;

  /// Get the image id.
  String get imageId;
}

/// General purpose image, usage not specified.
@MappableClass()
final class ImageCacheGeneralRequest extends ImageCacheRequest
    with ImageCacheGeneralRequestMappable {
  /// Constructor.
  const ImageCacheGeneralRequest(super.imageUrl);

  @override
  String get imageId => super.imageUrl;
}

/// Request to cached user avatar.
@MappableClass()
final class ImageCacheUserAvatarRequest extends ImageCacheRequest
    with ImageCacheUserAvatarRequestMappable {
  /// ImageUrl
  const ImageCacheUserAvatarRequest({
    required this.username,
    required String imageUrl,
  }) : super(imageUrl);

  /// Extra field for username to locate the request and response.
  final String username;

  @override
  String get imageId => username;
}
