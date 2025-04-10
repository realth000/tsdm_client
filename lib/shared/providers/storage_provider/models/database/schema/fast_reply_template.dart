part of 'schema.dart';

/// Table for reply a post with super fast speed.
///
/// Each template is a text using it.
@DataClassName('FastReplyTemplateEntity')
final class FastReplyTemplate extends Table {
  /// User holding the template.
  IntColumn get uid => integer()();

  /// Name of the template.
  TextColumn get name => text()();

  /// Data to reply.
  TextColumn get data => text()();

  /// The time last used this template.
  DateTimeColumn get lastUsedTime => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {uid, name};
}
