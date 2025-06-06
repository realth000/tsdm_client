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

  /// Watch all templates.
  Stream<List<FastRateTemplateEntity>> watchAll() {
    return select(fastRateTemplate).watch();
  }

  /// Insert template.
  Future<int> insertOrUpdate(FastRateTemplateCompanion rate) async {
    // Delete the same one if already have it.
    // FIXME: This seems an issue in drift: when insertOrUpdate, if item changes, watch() not produce the change.
    if ((await (select(fastRateTemplate)..where((e) => e.name.equals(rate.name.value))).getSingleOrNull()) != null) {
      await (delete(fastRateTemplate)..where((e) => e.name.equals(rate.name.value))).go();
    }
    return into(fastRateTemplate).insertOnConflictUpdate(rate);
  }

  /// Delete all templates in table.
  Future<int> deleteAll() async {
    return delete(fastRateTemplate).go();
  }

  /// Delete by template [name].
  Future<int> deleteByName(String name) async {
    return (delete(fastRateTemplate)..where((e) => e.name.equals(name))).go();
  }
}
