part of 'notification_bloc.dart';

/// Event of notification.
@MappableClass()
sealed class NotificationEvent with NotificationEventMappable {
  const NotificationEvent();
}

/// Requested to refresh notification.
@MappableClass()
final class NotificationRefreshRequested extends NotificationEvent
    with NotificationRefreshRequestedMappable {}

/// Requested to load more notification from the next page.
@MappableClass()
final class NotificationLoadMoreRequested extends NotificationEvent
    with NotificationLoadMoreRequestedMappable {}
