import 'package:isar/isar.dart';

part '../../../../../generated/shared/providers/storage_provider/models/database/settings.g.dart';

/// One item in [Isar] database to store one item in app settings.
///
/// Related link: https://github.com/isar/isar/discussions/1066
@Collection()
class DatabaseSettings {
  /// Constructor.
  DatabaseSettings({
    required this.id,
    required this.name,
    required this.valueType,
    this.stringValue,
    this.intValue,
    this.doubleValue,
    this.boolValue,
    this.dateTimeValue,
    this.stringListValue,
    this.intListValue,
    this.doubleListValue,
    this.boolListValue,
    this.dateTimeListValue,
  });

  /// Build a settings item from [String].
  DatabaseSettings.fromString({
    required this.id,
    required this.name,
    required this.stringValue,
  }) : valueType = SettingsValueType.string;

  /// Build a settings item from [int].
  DatabaseSettings.fromInt({
    required this.id,
    required this.name,
    required this.intValue,
  }) : valueType = SettingsValueType.int;

  /// Build a settings item from [double].
  DatabaseSettings.fromDouble({
    required this.id,
    required this.name,
    required this.doubleValue,
  }) : valueType = SettingsValueType.double;

  /// Build a settings item from [bool].
  DatabaseSettings.fromBool({
    required this.id,
    required this.name,
    required this.boolValue,
  }) : valueType = SettingsValueType.bool;

  /// Build a settings item from [DateTime].
  DatabaseSettings.fromDateTime({
    required this.id,
    required this.name,
    required this.dateTimeValue,
  }) : valueType = SettingsValueType.dateTime;

  /// Build a settings item from [List] of [String].
  DatabaseSettings.fromStringList({
    required this.id,
    required this.name,
    required this.stringListValue,
  }) : valueType = SettingsValueType.stringList;

  /// Build a settings item from [List] of [int].
  DatabaseSettings.fromIntList({
    required this.id,
    required this.name,
    required this.intListValue,
  }) : valueType = SettingsValueType.intList;

  /// Build a settings item from [List] of [double].
  DatabaseSettings.fromDoubleList({
    required this.id,
    required this.name,
    required this.doubleListValue,
  }) : valueType = SettingsValueType.doubleList;

  /// Build a settings item from [List] of [bool].
  DatabaseSettings.fromBoolList({
    required this.id,
    required this.name,
    required this.boolListValue,
  }) : valueType = SettingsValueType.boolList;

  /// Build a settings item from [List] of [DateTime].
  DatabaseSettings.fromDateTimeList({
    required this.id,
    required this.name,
    required this.dateTimeListValue,
  }) : valueType = SettingsValueType.dateTimeList;

  /// Database item id.
  @Id()
  int id;

  /// Settings key name.
  @Index(unique: true)
  String name;

  /// Indicate settings value type.
  @EnumValue()
  SettingsValueType valueType;

  /// Value used as [String].
  String? stringValue;

  /// Value used as [int].
  int? intValue;

  /// Value used as [double].
  double? doubleValue;

  /// Value used as [bool].
  bool? boolValue;

  /// Value used as [DateTime].
  DateTime? dateTimeValue;

  /// Value used as [List] of [String].
  List<String>? stringListValue;

  /// Value used as [List] of [int].
  List<int>? intListValue;

  /// Value used as [List] of [double].
  List<double>? doubleListValue;

  /// Value used as [List] of [bool].
  List<bool>? boolListValue;

  /// Value used as [List] of [DateTime].
  List<DateTime>? dateTimeListValue;
}

/// Record the value type in [DatabaseSettings]
enum SettingsValueType {
  /// Type is [String]
  string,

  /// Type is [int]
  int,

  /// Type is [double]
  double,

  /// Type is [bool]
  bool,

  /// Type is [DateTime]
  dateTime,

  /// TYpe is [List] of [String]
  stringList,

  /// Type is [List] of [int]
  intList,

  /// Type is [List] of [double]
  doubleList,

  /// Type is [List] of [bool]
  boolList,

  /// Type is [List] of [DateTime]
  dateTimeList,
}
