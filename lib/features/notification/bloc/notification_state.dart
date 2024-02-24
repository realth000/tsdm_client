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
    this.status = NotificationStatus.initial,
    this.noticeList = const [],
  });

  /// Status.
  final NotificationStatus status;

  /// All fetched [Notice].
  final List<Notice> noticeList;
}
