part of 'notification_bloc.dart';

/// Event of notification.
@MappableClass()
sealed class NotificationEvent with NotificationEventMappable {
  const NotificationEvent();
}

/// User required to refresh the notification page.
@MappableClass()
final class NotificationRefreshNoticeRequired extends NotificationEvent
    with NotificationRefreshNoticeRequiredMappable {}
