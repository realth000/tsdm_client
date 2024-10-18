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
