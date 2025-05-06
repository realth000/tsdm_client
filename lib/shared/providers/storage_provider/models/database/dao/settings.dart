part of 'dao.dart';

/// DAO for table [Settings].
@DriftAccessor(tables: [Settings])
final class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin, LoggerMixin {
  /// Constructor.
  SettingsDao(super.db);

  /// Get all settings record.
  Future<List<SettingsEntity>> getAll() async {
    return select(settings).get();
  }

  /// Get value of type [T] that stored with name [name].
  ///
  /// Supported [T]:
  ///
  /// * [String]
  /// * int
  /// * bool
  /// * double
  /// * [DateTime]
  /// * [Offset]
  /// * [Size]
  /// * [List] of [String]
  /// * [List] of int
  Future<T?> getValueByName<T>(String name) async {
    final value = await (select(settings)..where((e) => e.name.equals(name))).getSingleOrNull();
    if (value == null) {
      info('failed to get value by name "$name": value not exists');
      return null;
    }
    if (T == String) {
      return value.stringValue! as T;
    } else if (T == int) {
      return value.intValue! as T;
    } else if (T == bool) {
      return value.boolValue! as T;
    } else if (T == double) {
      return value.doubleValue! as T;
    } else if (T == DateTime) {
      return value.dateTimeValue! as T;
    } else if (T == Offset) {
      return value.offsetValue! as T;
    } else if (T == Size) {
      return value.sizeValue! as T;
    } else if (T == List<String>) {
      return value.stringListValue! as T;
    } else if (T == List<int>) {
      return value.intListValue! as T;
    }
    error('failed to get value by name "$name": unsupported type $T');
    return null;
  }

  /// Save [value] of name [name]
  ///
  /// Supported [T]:
  ///
  /// * [String]
  /// * int
  /// * bool
  /// * double
  /// * [DateTime]
  /// * [Offset]
  /// * [Size]
  /// * [List] of [String]
  /// * [List] of int
  Future<void> setValue<T>(String name, T value) async {
    final SettingsCompanion companion;
    if (T == String) {
      companion = SettingsCompanion(name: Value(name), stringValue: Value(value as String));
    } else if (T == int) {
      companion = SettingsCompanion(name: Value(name), intValue: Value(value as int));
    } else if (T == bool) {
      companion = SettingsCompanion(name: Value(name), boolValue: Value(value as bool));
    } else if (T == double) {
      companion = SettingsCompanion(name: Value(name), doubleValue: Value(value as double));
    } else if (T == DateTime) {
      companion = SettingsCompanion(name: Value(name), dateTimeValue: Value(value as DateTime));
    } else if (T == Offset) {
      companion = SettingsCompanion(name: Value(name), offsetValue: Value(value as Offset));
    } else if (T == Size) {
      companion = SettingsCompanion(name: Value(name), sizeValue: Value(value as Size));
    } else if (T == List<String>) {
      companion = SettingsCompanion(name: Value(name), stringListValue: Value(value as List<String>));
    } else if (T == List<int>) {
      companion = SettingsCompanion(name: Value(name), intListValue: Value(value as List<int>));
    } else {
      // Unsupported types.
      error(
        'intend to save unsupported settings type: '
        'key=$name, value=$value, type=$T',
      );
      return;
    }

    await into(settings).insertOnConflictUpdate(companion);
  }

  /// Delete record by its [name].
  Future<int> deleteByName(String name) async {
    return (delete(settings)..where((e) => e.name.equals(name))).go();
  }
}
