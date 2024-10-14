part of 'dao.dart';

/// DAO for all notification related tables.
@DriftAccessor(
  tables: [
    Notice,
    PersonalMessage,
    BroadcastMessage,
  ],
)
final class NotificationDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationDaoMixin {
  /// Constructor.
  NotificationDao(super.db);
}
