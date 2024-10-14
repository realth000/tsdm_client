part of 'cookie_data.dart';

/// Temporary data class for recording current user's info and credential.
///
/// Can be used in login progress, where we have incomplete user info and need
/// to update.
final class _CurrentUserCookie {
  const _CurrentUserCookie({
    this.userLoginInfo,
    this.cookie,
  });

  factory _CurrentUserCookie.empty() => const _CurrentUserCookie();

  final UserLoginInfo? userLoginInfo;
  final Map<String, String>? cookie;

  _CurrentUserCookie copyWith({
    UserLoginInfo? userLoginInfo,
    Map<String, String>? cookie,
  }) =>
      _CurrentUserCookie(
        userLoginInfo: this.userLoginInfo?.copyWith(
                  username: userLoginInfo?.username,
                  uid: userLoginInfo?.uid,
                  // email: userLoginInfo?.email,
                ) ??
            this.userLoginInfo,
        cookie: cookie ?? this.cookie,
      );
}
