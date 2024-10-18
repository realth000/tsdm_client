part of 'notification_bloc.dart';

/// Status of notification.
enum NotificationStatus {
  /// Initial.
  initial,

  /// Loading.
  loading,

  /// Success.
  success,

  /// Failure.
  failure,
}

/// State of notification.
@MappableClass()
class NotificationState with NotificationStateMappable {
  /// Constructor.
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.noticeList = const [],
    this.personalMessageList = const [],
    this.broadcastMessageList = const [],
  });

  /// Notice tab status.
  final NotificationStatus status;

  /// All fetched [NoticeV2].
  final List<NoticeV2> noticeList;

  /// All fetched [PersonalMessageV2].
  final List<PersonalMessageV2> personalMessageList;

  /// All fetched [BroadcastMessageV2].
  final List<BroadcastMessageV2> broadcastMessageList;
}
