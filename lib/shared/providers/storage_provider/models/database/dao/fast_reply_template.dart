part of 'dao.dart';

/// DAO for table [FastReplyTemplate]
@DriftAccessor(tables: [FastReplyTemplate])
final class FastReplyTemplateDao extends DatabaseAccessor<AppDatabase> with _$FastReplyTemplateDaoMixin {
  /// Constructor.
  FastReplyTemplateDao(super.attachedDatabase);

  /// Select all templates.
  Future<List<FastReplyTemplateEntity>> selectAll() async {
    return select(fastReplyTemplate).get();
  }

  /// Watch all template changes.
  Stream<List<FastReplyTemplateEntity>> watchAll() {
    return select(fastReplyTemplate).watch();
  }

  /// Insert template.
  Future<int> insertOrUpdate(FastReplyTemplateCompanion reply) async {
    // Delete the same one if already have it.
    // FIXME: This seems an issue in drift: when insertOrUpdate, if item changes, watch() not produce the change.
    if ((await (select(fastReplyTemplate)..where((e) => e.name.equals(reply.name.value))).getSingleOrNull()) != null) {
      await (delete(fastReplyTemplate)..where((e) => e.name.equals(reply.name.value))).go();
    }
    return into(fastReplyTemplate).insertOnConflictUpdate(reply);
  }

  /// Delete all templates in table.
  Future<int> deleteAll() async {
    return delete(fastReplyTemplate).go();
  }

  /// Delete the template specified by template [name].
  Future<int> deleteByName(String name) async {
    return (delete(fastReplyTemplate)..where((e) => e.name.equals(name))).go();
  }
}
