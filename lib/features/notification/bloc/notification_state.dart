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
  failure,

  /// Load more data
  loadingNextPage,

  /// All data loaded.
  noMoreData,
}

/// Basic notification.
///
/// Common members of notification where T can be:
///
/// * [Notice]
/// * [PersonalMessage].
/// * [BroadcastMessage].
@MappableClass()
sealed class NotificationBaseState<T> with NotificationBaseStateMappable<T> {
  /// Constructor.
  const NotificationBaseState({
    this.status = NotificationStatus.initial,
    this.pageNumber = 1,
    this.hasNextPage = false,
    this.noticeList = const [],
  });

  /// Status.
  final NotificationStatus status;

  /// Current loaded page number.
  final int pageNumber;

  /// Whether has next page to load more notification.
  final bool hasNextPage;

  /// All fetched notice,
  final List<T> noticeList;
}

/// State of notice tab.
@MappableClass()
final class NoticeState extends NotificationBaseState<Notice>
    with NoticeStateMappable {
  /// Constructor.
  const NoticeState({
    super.status,
    super.pageNumber,
    super.hasNextPage,
    super.noticeList,
  }) : super();
}

/// State of personal message tab.
@MappableClass()
final class PersonalMessageState extends NotificationBaseState<PersonalMessage>
    with PersonalMessageStateMappable {
  /// Constructor.
  const PersonalMessageState({
    super.status,
    super.pageNumber,
    super.hasNextPage,
    super.noticeList,
  }) : super();
}

/// State of personal message tab.
@MappableClass()
final class BroadcastMessageState
    extends NotificationBaseState<BroadcastMessage>
    with BroadcastMessageStateMappable {
  /// Constructor.
  const BroadcastMessageState({
    super.status,
    super.pageNumber,
    super.hasNextPage,
    super.noticeList,
  }) : super();
}
