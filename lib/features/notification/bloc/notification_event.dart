part of 'notification_bloc.dart';

/// Event of notification.
sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// User required to refresh the notification page.
final class NotificationRefreshNoticeRequired extends NotificationEvent {}
