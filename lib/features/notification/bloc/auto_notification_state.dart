part of 'auto_notification_cubit.dart';

/// Base class of state.
@MappableClass()
sealed class AutoNoticeState with AutoNoticeStateMappable {
  /// Constructor.
  const AutoNoticeState(this.duration);

  /// Duration to fetch notice.
  final Duration duration;
}

/// Initial state.
@MappableClass()
final class AutoNoticeStateStopped extends AutoNoticeState
    with AutoNoticeStateStoppedMappable {
  /// Constructor.
  const AutoNoticeStateStopped(super.duration);
}

/// Waiting for next scheduled time to do refresh notice.
@MappableClass()
final class AutoNoticeStateWaiting extends AutoNoticeState
    with AutoNoticeStateWaitingMappable {
  /// Constructor.
  const AutoNoticeStateWaiting(super.duration);
}

/// Pending latest notice state.
///
/// Fetching notice from server, checking for unread new notice, updating
/// notice state in cache, and more.
@MappableClass()
final class AutoNoticeStatePending extends AutoNoticeState
    with AutoNoticeStatePendingMappable {
  /// Constructor.
  const AutoNoticeStatePending(this.notice, super.duration);

  /// Notice fetch result.
  ///
  /// Set to now when waiting for server response.
  final NotificationV2? notice;
}
