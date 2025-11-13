part of 'dao.dart';

/// DAO for table [FastRateTemplate].
@DriftAccessor(tables: [FastRateTemplate])
final class FastRateTemplateDao extends DatabaseAccessor<AppDatabase> with _$FastRateTemplateDaoMixin {
  /// Constructor.
  FastRateTemplateDao(super.attachedDatabase);

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
