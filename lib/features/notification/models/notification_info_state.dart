part of 'models.dart';

/// Base state of [NotificationV2] state.
@MappableClass()
sealed class NotificationInfoState with NotificationInfoStateMappable {
  /// Constructor.
  const NotificationInfoState();
}

/// Fetching notification.
@MappableClass()
final class NotificationInfoStateLoading extends NotificationInfoState with NotificationInfoStateLoadingMappable {
  /// Constructor.
  const NotificationInfoStateLoading();
}

/// Fetched notice successfully.
@MappableClass()
final class NotificationInfoStateSuccess extends NotificationInfoState with NotificationInfoStateSuccessMappable {
  /// Constructor.
  const NotificationInfoStateSuccess(this.uid, this.info);

  /// User id of whom the fetch action on.
  final int uid;

  /// Fetched info.
  final NotificationV2 info;
}

/// Failed to fetch notification.
@MappableClass()
final class NotificationInfoStateFailure extends NotificationInfoState with NotificationInfoStateFailureMappable {
  /// Constructor.
  const NotificationInfoStateFailure();
}
