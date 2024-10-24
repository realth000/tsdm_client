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

  /// Select notice for user [uid] since [timestamp].
  ///
  /// [timestamp] is in seconds.
  Future<List<NoticeEntity>> selectNoticeSince({
    required int uid,
    required int timestamp,
  }) async {
    return (select(notice)
          ..where(
            (e) =>
                e.uid.equals(uid) & e.timestamp.isBiggerOrEqualValue(timestamp),
          )
          ..orderBy([
            (e) => OrderingTerm(
                  expression: e.timestamp,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  /// Select personal messages for user [uid] since [timestamp].
  ///
  /// [timestamp] is in seconds.
  Future<List<PersonalMessageEntity>> selectPersonalMessageSince({
    required int uid,
    required int timestamp,
  }) async {
    return (select(personalMessage)
          ..where(
            (e) =>
                e.uid.equals(uid) & e.timestamp.isBiggerOrEqualValue(timestamp),
          )
          ..orderBy([
            (e) => OrderingTerm(
                  expression: e.timestamp,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  /// Select broadcast messages for user [uid] since [timestamp].
  ///
  /// [timestamp] is in seconds.
  Future<List<BroadcastMessageEntity>> selectBroadcastMessageSince({
    required int uid,
    required int timestamp,
  }) async {
    return (select(broadcastMessage)
          ..where(
            (e) =>
                e.uid.equals(uid) & e.timestamp.isBiggerOrEqualValue(timestamp),
          )
          ..orderBy([
            (e) => OrderingTerm(
                  expression: e.timestamp,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  /// Insert notice [message] into table [notice].
  ///
  /// Note that notice is only generated by server and no modify is intend to be
  /// on it, so that only "insert" operation is planned, no upsert.
  Future<int> insertNotice(NoticeCompanion message) async {
    return into(notice).insertOnConflictUpdate(message);
  }

  /// Insert notice [message] into table [notice].
  ///
  /// Note that personal message is only generated by server and no modify is
  /// intend to be on it, so that only "insert" operation is planned, no upsert.
  Future<int> insertPersonalMessage(PersonalMessageCompanion message) async {
    return into(personalMessage).insertOnConflictUpdate(message);
  }

  /// Insert notice [message] into table [notice].
  ///
  /// Note that broadcast message is only generated by server and no modify is
  /// intend to be on it, so that only "insert" operation is planned, no upsert.
  Future<int> insertBroadcastMessage(BroadcastMessageCompanion message) async {
    return into(broadcastMessage).insertOnConflictUpdate(message);
  }

  /// Insert different types of many notice in one function call.
  Future<void> insertManyNotice({
    List<NoticeCompanion> noticeList = const [],
    List<PersonalMessageCompanion> personalMessageList = const [],
    List<BroadcastMessageCompanion> broadcastMessageList = const [],
  }) async {
    return transaction(() async {
      for (final n in noticeList) {
        await into(notice).insertOnConflictUpdate(n);
      }
      for (final p in personalMessageList) {
        await into(personalMessage).insertOnConflictUpdate(p);
      }
      for (final b in broadcastMessageList) {
        await into(broadcastMessage).insertOnConflictUpdate(b);
      }
    });
  }

  /// Delete all [notice] for user [uid].
  Future<int> deleteNoticeByUid(int uid) async {
    return (delete(notice)..where((e) => e.uid.equals(uid))).go();
  }

  /// Delete all [personalMessage] for user [uid].
  Future<int> deletePersonalMessageByUid(int uid) async {
    return (delete(personalMessage)..where((e) => e.uid.equals(uid))).go();
  }

  /// Delete all [broadcastMessage] for user [uid].
  Future<int> deleteBroadcastMessageByUid(int uid) async {
    return (delete(broadcastMessage)..where((e) => e.uid.equals(uid))).go();
  }
}
