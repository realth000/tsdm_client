part of 'schema.dart';

/// Table recording fate rate template.
///
/// Each template stores a series of kinds of credits to rate users.
///
/// Most columns in this is not going to change so we do not use English words to name them because the fields in
/// database is far much better to be consist through time, not like variable names or translations.
@DataClassName('FastRateTemplateEntity')
class FastRateTemplate extends Table {
  /// Name of the template.
  TextColumn get name => text()();

  /// Attr 威望
  IntColumn get ww => integer()();

  /// Attr 天使币
  IntColumn get tsb => integer()();

  /// Attr 宣传
  IntColumn get xc => integer()();

  /// Attr 天然
  IntColumn get tr => integer()();

  /// Attr 腹黑
  IntColumn get fh => integer()();

  /// Attr 精灵
  IntColumn get jl => integer()();

  /// The special attribute changes through time.
  IntColumn get special => integer()();

  /// Another special attribute changes through time.
  ///
  /// Optioanl as not used in most time.
  IntColumn get special2 => integer().nullable()();

  /// The time last used this template.
  DateTimeColumn get lastUsedTime => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}
