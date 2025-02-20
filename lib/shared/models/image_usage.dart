part of 'models.dart';

/// Enum describes all image usages in this app.
///
/// Use this enum to classify different image cache.
///
/// # CAUTION
///
/// This type is used in storage, do NOT change it's fields order or delete
/// fields.
enum ImageUsage {
  /// Other unclassified types.
  other,

  /// User avatar.
  userAvatar,
}

/// Base class of all image usage.
@MappableClass()
sealed class ImageUsageInfo with ImageUsageInfoMappable {
  /// Constructor.
  const ImageUsageInfo();
}

/// Associated info for [ImageUsage.other].
@MappableClass()
final class ImageUsageInfoOther extends ImageUsageInfo with ImageUsageInfoOtherMappable {
  /// Constructor.
  const ImageUsageInfoOther();
}

/// Associated info for [ImageUsage.userAvatar].
@MappableClass()
final class ImageUsageInfoUserAvatar extends ImageUsageInfo with ImageUsageInfoUserAvatarMappable {
  /// Constructor.
  const ImageUsageInfoUserAvatar(this.username);

  /// Username.
  final String username;
}
