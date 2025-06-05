part of 'dao.dart';

/// DAO for table [FastRateTemplate].
@DriftAccessor(tables: [FastRateTemplate])
final class FastRateTemplateDao extends DatabaseAccessor<AppDatabase> with _$FastRateTemplateDaoMixin {
  /// Constructor.
  FastRateTemplateDao(super.db);

  /// Get all templates.
  Future<List<FastRateTemplateEntity>> selectAll() async {
    return select(fastRateTemplate).get();
  }

  /// Get all templates for user with [uid].
  Future<List<FastRateTemplateEntity>> selectByUid(int uid) async {
    return (select(fastRateTemplate)..where((e) => e.uid.equals(uid))).get();
  }

  /// Watch all templates.
  Stream<List<FastRateTemplateEntity>> watchAll() {
    return select(fastRateTemplate).watch();
  }

  /// Insert template.
  Future<int> insertOrUpdate(FastRateTemplateCompanion rate) async {
    // Delete the same one if already have it.
    // FIXME: This seems an issue in drift: when insertOrUpdate, if item changes, watch() not produce the change.
    if ((await (select(
          fastRateTemplate,
        )..where((e) => e.name.equals(rate.name.value) & e.uid.equals(rate.uid.value))).getSingleOrNull()) !=
        null) {
      await (delete(
        fastRateTemplate,
      )..where((e) => e.name.equals(rate.name.value) & e.uid.equals(rate.uid.value))).go();
    }
    return into(fastRateTemplate).insertOnConflictUpdate(rate);
  }

  /// Delete all templates in table.
  Future<int> deleteAll() async {
    return delete(fastRateTemplate).go();
  }

  /// Delete all templates for user [uid].
  Future<int> deleteByUid(int uid) async {
    return (delete(fastRateTemplate)..where((e) => e.uid.equals(uid))).go();
  }

  /// Delete all templates for user [uid] and template [name].
  Future<int> deleteByUidAndName(int uid, String name) async {
    return (delete(fastRateTemplate)..where((e) => e.uid.equals(uid) & e.name.equals(name))).go();
  }
}
