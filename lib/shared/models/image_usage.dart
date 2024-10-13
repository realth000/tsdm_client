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
  /// Shared in top level wide.
  ///
  /// * Images in homepage carousel.
  /// * Medal images.
  /// * Title images.
  topLevel,

  /// Used in forum wide.
  ///
  /// * Outer cover.
  /// * Inner top cover.
  ///
  /// Persists in very long time.
  forumLevel,

  /// Used in user wide.
  ///
  /// * User avatar.
  /// * Image in user signature.
  ///
  /// * May be persistent and may not.
  /// * May contains large size/mount of pictures.
  userLevel,

  /// Used in a thread.
  ///
  /// * Images in thread/post.
  ///
  /// May contains large size/mount of pictures.
  /// Recommend to persists in a short time.
  threadLevel,
}
