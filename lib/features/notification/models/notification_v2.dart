part of 'models.dart';

/// Model for the result of fetch notification API.
@MappableClass()
final class NotificationV2 with NotificationV2Mappable {
  /// Constructor.
  const NotificationV2({
    required this.status,
    required this.noticeList,
    required this.personalMessageList,
    required this.broadcastMessageList,
  });

  /// Response status.
  final int status;

  /// All notices fetched.
  @MappableField(key: 'notification')
  final List<NoticeV2> noticeList;

  /// All personal messages.
  @MappableField(key: 'private_message')
  final List<PersonalMessageV2> personalMessageList;

  /// All broadcast messages.
  @MappableField(key: 'public_message')
  final List<BroadcastMessageV2> broadcastMessageList;

  /// Return the datetime of latest notification, no matter the notification is a notice, personal message or
  /// broadcast message.
  ///
  /// Use this method to find the latest timestamp covers all notification generated that confirmed by the server side.
  /// Which means: all notification till this time have been confirmed and provided by the server.
  ///
  /// Note that all timestamp in notification model is in second so there is a chance of missing notification, but
  /// this behavior is inside the server side, we may do nothing on it.
  ///
  /// ## CAUTION
  ///
  /// Return null if all types of notification are empty.
  DateTime? latestTimestamp() {
    final noticeTime = switch (noticeList.isEmpty) {
      true => 0,
      false => noticeList.map((e) => e.timestamp).reduce(math.max),
    };
    final pmTime = switch (personalMessageList.isEmpty) {
      true => 0,
      false => personalMessageList.map((e) => e.timestamp).reduce(math.max),
    };
    final bmTime = switch (broadcastMessageList.isEmpty) {
      true => 0,
      false => broadcastMessageList.map((e) => e.timestamp).reduce(math.max),
    };

    // The latest timestamp (in seconds) of notification time.
    final latestTime = [noticeTime, pmTime, bmTime].reduce(math.max);

    if (latestTime == 0) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(latestTime * 1000);
  }
}
