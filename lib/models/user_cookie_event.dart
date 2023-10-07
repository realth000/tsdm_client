/// Types of [UserCookieEvent]
enum UserCookieEventType {
  /// Update for a single user.
  ///
  /// As this type, [UserCookieEvent.username], and
  /// [UserCookieEvent.cookie] should not be null.
  update,

  /// Delete single user's cookie.
  ///
  /// As this type, [UserCookieEvent.username] should not
  /// be null.
  delete,
}

/// Model represent single cookie for single user.
class UserCookieEvent {
  UserCookieEvent.update({
    required this.username,
    required this.cookie,
  }) : eventType = UserCookieEventType.update;

  UserCookieEvent.delete({
    required this.username,
  })  : eventType = UserCookieEventType.delete,
        cookie = {};

  final UserCookieEventType eventType;
  final String username;
  final Map<String, String> cookie;
}
