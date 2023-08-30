import 'package:freezed_annotation/freezed_annotation.dart';

part '../generated/models/user.freezed.dart';

/// Author of a thread.
///
/// Contains name and user page url.
@freezed
class User with _$User {
  /// Freezed constructor.
  const factory User({
    /// User name.
    required String name,

    /// User homepage url.
    required String url,

    /// User id.
    ///
    /// For somewhere we can not get user id, this can not be "required".
    String? uid,

    /// User avatar, may be null.
    String? avatarUrl,
  }) = _User;
}
