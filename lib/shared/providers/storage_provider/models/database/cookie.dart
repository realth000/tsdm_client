import 'package:isar/isar.dart';

part '../../../../../generated/shared/providers/storage_provider/models/database/cookie.g.dart';

/// Cookie format to save in isar database.
///
/// Each cookie convert to one item in isar.
/// Note that now only each user having one cookie, which means:
/// * Updating cookie will override the former one.
/// * A cookie with false [ignoreExpires] and false [persistSession] will
///   override existing cookie which has true [ignoreExpires] and true
///   [persistSession].
/// Till now one cookie is enough for one user.
@Collection()
class DatabaseCookie {
  /// Constructor.
  DatabaseCookie({
    required this.id,
    required this.username,
    required this.cookie,
    this.ignoreExpires,
    this.persistSession,
  });

  /// Database item id.
  @Id()
  int id;

  /// Username
  ///
  /// Allow update and duplicate in different cookies
  ///
  /// Server side does not allow same username so make this unique is OK.
  @Index(unique: true)
  String username;

  /// Cookie value string of '.index'
  Map<String, dynamic> cookie;

  /// Record the same name value passed from PersistCookieJar.
  ///
  /// Not used internally.
  bool? ignoreExpires;

  /// Record the same name value passed from PersistCookieJar.
  ///
  /// Not used internally.
  bool? persistSession;
}
