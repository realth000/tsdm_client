part of 'notification_bloc.dart';

/// Event of notification.
@MappableClass()
sealed class NotificationEvent with NotificationEventMappable {
  const NotificationEvent();
}

/// Required to refresh all kinds of notification.
@MappableClass()
final class NotificationUpdateAllRequested extends NotificationEvent
    with NotificationUpdateAllRequestedMappable {}

/// Need to update the last fetch notification timestamp for current user in
/// storage.
@MappableClass()
final class NotificationRecordFetchTimeRequested extends NotificationEvent
    with NotificationRecordFetchTimeRequestedMappable {}

/// Mark a message as read.
@MappableClass()
final class NotificationMarkReadRequested extends NotificationEvent
    with NotificationMarkReadRequestedMappable {
  /// Constructor.
  const NotificationMarkReadRequested(this.recordMark);

  /// Purpose of this event.
  final RecordMark recordMark;
}

/// Mark all message of type as read.
@MappableClass()
final class NotificationMarkTypeReadRequested extends NotificationEvent
    with NotificationMarkTypeReadRequestedMappable {
  /// Constructor.
  const NotificationMarkTypeReadRequested({
    required this.markType,
    required this.markAsRead,
  });

  /// Purpose of this event.
  final NotificationType markType;

  /// Flag indicating mark as read or unread.
  final bool markAsRead;
}

/// Internal event.
///
/// Repository has fetched new info from server.
@MappableClass()
final class NotificationInfoFetched extends NotificationEvent
    with NotificationInfoFetchedMappable {
  /// Constructor.
  const NotificationInfoFetched(this.info);

  /// Latest fetched info.
  final NotificationInfoState info;
}
