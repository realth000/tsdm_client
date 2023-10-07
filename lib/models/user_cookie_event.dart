/// Types of [UserCookieEvent]
enum UserCookieEventType {
  /// Update for a single user.
  ///
  /// As this type, [UserCookieEvent.uid], [UserCookieEvent.username], and
  /// [UserCookieEvent.cookie] should not be null.
  update,

  /// Delete single user's cookie.
  ///
  /// As this type, [UserCookieEvent.uid], [UserCookieEvent.username] should not
  /// be null.
  delete,
}

/// Model represent single cookie for single user.
class UserCookieEvent {
  /// Allow [uid] to be null when update cookie, because sometimes we do not know
  /// [username] and should save cookie in database first.
  UserCookieEvent.update({
    required this.username,
    required this.cookie,
    this.uid,
  }) : eventType = UserCookieEventType.update;

  UserCookieEvent.delete({
    required int this.uid,
    required this.username,
  })  : eventType = UserCookieEventType.delete,
        cookie = {};

  final UserCookieEventType eventType;
  final int? uid;
  final String username;
  final Map<String, String> cookie;
}
