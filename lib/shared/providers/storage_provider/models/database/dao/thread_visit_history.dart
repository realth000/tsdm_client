part of 'dao.dart';

/// DAO for table [ThreadVisitHistory].
@DriftAccessor(tables: [ThreadVisitHistory])
final class ThreadVisitHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$ThreadVisitHistoryDaoMixin {
  /// Constructor.
  ThreadVisitHistoryDao(super.db);

  /// Get all history, all users.
  Future<List<ThreadVisitHistoryEntity>> selectAll() async {
    return select(threadVisitHistory).get();
  }

  /// Get all history with the user specified with [uid].
  ///
  /// Only [uid]'s user's visit history will be returned.
  Future<List<ThreadVisitHistoryEntity>> selectByUid(int uid) async {
    return (select(threadVisitHistory)..where((e) => e.uid.equals(uid))).get();
  }

  /// Get all history on thread with [tid].
  ///
  /// Only [tid]'s thread's visit history will be returned.
  Future<List<ThreadVisitHistoryEntity>> selectByTid(int tid) async {
    return (select(threadVisitHistory)..where((e) => e.tid.equals(tid))).get();
  }

  /// Insert or update item [companion].
  ///
  /// All info are provided by the caller.
  Future<int> upsertVisitHistory(ThreadVisitHistoryCompanion companion) async {
    return into(threadVisitHistory).insertOnConflictUpdate(companion);
  }

  /// Delete history by user's [uid] or thread's [tid].
  ///
  /// Can be used as:
  ///
  /// * [uid] != null && [tid] != null: Delete user visit a certain thread.
  /// * [uid] != null && [tid] == null: Delete user visit all thread.
  /// * [uid] == null && [tid] != null: Delete all history on a certain thread.
  ///
  /// Do nothing if both [uid] and [tid] are null.
  Future<int> deleteByUidOrTid({int? uid, int? tid}) async =>
      switch ((uid, tid)) {
        (final int u, final int t) => (delete(threadVisitHistory)
              ..where((e) => e.uid.equals(u) & e.tid.equals(t)))
            .go(),
        (final int u, null) =>
          (delete(threadVisitHistory)..where((e) => e.uid.equals(u))).go(),
        (null, final int t) =>
          (delete(threadVisitHistory)..where((e) => e.tid.equals(t))).go(),
        (null, null) => 0,
      };

  /// Delete all items in table.
  ///
  /// Use with caution.
  Future<int> deleteAll() async {
    return delete(threadVisitHistory).go();
  }
}
