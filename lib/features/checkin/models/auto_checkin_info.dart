part of 'models.dart';

/// Information about current checkin progress.
@MappableClass()
final class AutoCheckinInfo with AutoCheckinInfoMappable {
  /// Constructor.
  const AutoCheckinInfo({
    required this.skipped,
    required this.waiting,
    required this.running,
    required this.succeeded,
    required this.failed,
    required this.notAuthed,
  });

  /// Construct an instance with empty data.
  factory AutoCheckinInfo.empty() =>
      const AutoCheckinInfo(skipped: [], waiting: [], running: [], succeeded: [], failed: [], notAuthed: []);

  /// Construct a instance with starting point values.
  factory AutoCheckinInfo.start({required List<UserLoginInfo> waiting, required List<UserLoginInfo> running}) =>
      AutoCheckinInfo(skipped: [], waiting: waiting, running: running, succeeded: [], failed: [], notAuthed: []);

  /// Users skipped the checkin progress because of the last checkin time.
  final List<UserLoginInfo> skipped;

  /// Users waiting for progress.
  ///
  /// This field is used for users that blocked by the checkin concurrency
  /// limit.
  final List<UserLoginInfo> waiting;

  /// Users running in progress.
  final List<UserLoginInfo> running;

  /// Users successfully checked in.
  final List<(UserLoginInfo, CheckinResult)> succeeded;

  /// Users failed to check in.
  ///
  /// Only users failed with reasons except unauthenticated state are stored
  /// here. For those users who failed to checkin due to auth failure, store
  /// them in [notAuthed].
  final List<(UserLoginInfo, CheckinResult)> failed;

  /// Users failed to check in and the failure reason is guessed to be the
  /// unauthenticated state, maybe the cookie is expired.
  ///
  /// Users in this field are suggested to login another time to refresh cookie.
  final List<(UserLoginInfo, CheckinResult)> notAuthed;
}
