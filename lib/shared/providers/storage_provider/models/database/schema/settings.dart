part of 'schema.dart';

/// Table for app settings.
///
/// Each row stores a key of setting.
@DataClassName('SettingsEntity')
class Settings extends Table {
  /// Name
  TextColumn get name => text()();

  /// Int value.
  IntColumn get intValue => integer().nullable()();

  /// Double type value.
  RealColumn get doubleValue => real().nullable()();

  /// String type value.
  TextColumn get stringValue => text().nullable()();

  /// Bool type value.
  BoolColumn get boolValue => boolean().nullable()();

  /// [DateTime] type value.
  DateTimeColumn get dateTimeValue => dateTime().nullable()();

  /// Ui `Size` type value.
  ///
  /// Added in v3.
  TextColumn get sizeValue => text().map(const SizeConverter()).nullable()();

  /// Ui `Offset` type value.
  ///
  /// Added in v3.
  TextColumn get offsetValue => text().map(const OffsetConverter()).nullable()();

  /// List of string.
  ///
  /// Added in v9.
  TextColumn get stringListValue => text().map(const StringListConverter()).nullable()();

  /// List of int.
  ///
  /// Added in v9.
  TextColumn get intListValue => text().map(const IntListConverter()).nullable()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}
