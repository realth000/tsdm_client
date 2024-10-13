part of 'notification_bloc.dart';

/// Status of notification.
enum NotificationStatus {
  /// Initial.
  initial,

  /// Loading.
  loading,

  /// Success.
  success,

  /// Failed.
  failed,
}

/// State of notification.
@MappableClass()
class NotificationState with NotificationStateMappable {
  /// Constructor.
  const NotificationState({
    this.noticeStatus = NotificationStatus.initial,
    this.personalMessageStatus = NotificationStatus.initial,
    this.broadcastMessageStatus = NotificationStatus.initial,
    this.noticeList = const [],
    this.personalMessageList = const [],
    this.broadcastMessageList = const [],
  });

  /// Notice tab status.
  final NotificationStatus noticeStatus;

  /// Personal message status.
  final NotificationStatus personalMessageStatus;

  /// Broadcast message status.
  final NotificationStatus broadcastMessageStatus;

  /// All fetched [Notice].
  final List<Notice> noticeList;

  /// All fetched [PersonalMessage].
  final List<PersonalMessage> personalMessageList;

  /// All fetched [BroadcastMessage].
  final List<BroadcastMessage> broadcastMessageList;
}
