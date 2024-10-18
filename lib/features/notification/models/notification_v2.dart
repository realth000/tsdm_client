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
}
