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

/// User required to refresh the private personal message tab.
@MappableClass()
final class NotificationRefreshPersonalMessageRequired extends NotificationEvent
    with NotificationRefreshPersonalMessageRequiredMappable {}

/// User required to refresh the broadcast message tab.
@MappableClass()
final class NotificationRefreshBroadcastMessageRequired
    extends NotificationEvent
    with NotificationRefreshBroadcastMessageRequiredMappable {}
