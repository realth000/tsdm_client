part of 'dao.dart';

/// DAO for table [Settings].
@DriftAccessor(tables: [Settings])
final class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin, LoggerMixin {
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
  Future<T?> getValueByName<T>(String name) async {
    final value = await (select(settings)..where((e) => e.name.equals(name)))
        .getSingleOrNull();
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
    }
    info('failed to get value by name "$name": unsupported type $T');
    return null;
  }

  /// Save [value] of name [name]
  Future<void> setValue<T>(String name, T value) async {
    final SettingsCompanion companion;
    if (T == String) {
      companion = SettingsCompanion(
        name: Value(name),
        stringValue: Value(value as String),
      );
    } else if (T == int) {
      companion = SettingsCompanion(
        name: Value(name),
        intValue: Value(value as int),
      );
    } else if (T == bool) {
      companion = SettingsCompanion(
        name: Value(name),
        boolValue: Value(value as bool),
      );
    } else if (T == double) {
      companion = SettingsCompanion(
        name: Value(name),
        doubleValue: Value(value as double),
      );
    } else {
      // Unsupported types.
      error('intend to save unsupported settings type: '
          'key=$name, value=$value, type=$T');
      return;
    }

    await into(settings).insertOnConflictUpdate(companion);
  }

  /// Delete record by its [name].
  Future<int> deleteByName(String name) async {
    return (delete(settings)..where((e) => e.name.equals(name))).go();
  }
}
