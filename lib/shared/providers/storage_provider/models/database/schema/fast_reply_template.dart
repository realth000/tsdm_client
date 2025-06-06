part of 'schema.dart';

/// Table for reply a post with super fast speed.
///
/// Each template is a text using it.
@DataClassName('FastReplyTemplateEntity')
class FastReplyTemplate extends Table {
  /// Name of the template.
  TextColumn get name => text()();

  /// Data to reply.
  TextColumn get data => text()();

  /// The time last used this template.
  DateTimeColumn get lastUsedTime => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}
