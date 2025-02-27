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
    this.latestTime,
  });

  /// Notice tab status.
  final NotificationStatus status;

  /// All fetched [NoticeV2].
  final List<NoticeV2> noticeList;

  /// All fetched [PersonalMessageV2].
  final List<PersonalMessageV2> personalMessageList;

  /// All fetched [BroadcastMessageV2].
  final List<BroadcastMessageV2> broadcastMessageList;

  /// The timestamp of latest notification.
  ///
  /// This field stores the latest timestamp of notification.
  /// For a complete and consist notification fetch time, use this field for the next fetch since it's just continue
  /// since the latest fetched notification confirmed by the server side.
  final DateTime? latestTime;
}
