import 'package:isar/isar.dart';

part '../../../../../generated/shared/providers/storage_provider/models/database/settings.g.dart';

/// One item in [Isar] database to store one item in app settings.
///
/// Related link: https://github.com/isar/isar/discussions/1066
@Collection()
class DatabaseSettings {
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

  DatabaseSettings.fromString({
    required this.id,
    required this.name,
    required this.stringValue,
  }) : valueType = SettingsValueType.string;

  DatabaseSettings.fromInt({
    required this.id,
    required this.name,
    required this.intValue,
  }) : valueType = SettingsValueType.int;

  DatabaseSettings.fromDouble({
    required this.id,
    required this.name,
    required this.doubleValue,
  }) : valueType = SettingsValueType.double;

  DatabaseSettings.fromBool({
    required this.id,
    required this.name,
    required this.boolValue,
  }) : valueType = SettingsValueType.bool;

  DatabaseSettings.fromDateTime({
    required this.id,
    required this.name,
    required this.dateTimeValue,
  }) : valueType = SettingsValueType.dateTime;

  DatabaseSettings.fromStringList({
    required this.id,
    required this.name,
    required this.stringListValue,
  }) : valueType = SettingsValueType.stringList;

  DatabaseSettings.fromIntList({
    required this.id,
    required this.name,
    required this.intListValue,
  }) : valueType = SettingsValueType.intList;

  DatabaseSettings.fromDoubleList({
    required this.id,
    required this.name,
    required this.doubleListValue,
  }) : valueType = SettingsValueType.doubleList;

  DatabaseSettings.fromBoolList({
    required this.id,
    required this.name,
    required this.boolListValue,
  }) : valueType = SettingsValueType.boolList;

  DatabaseSettings.fromDateTimeList({
    required this.id,
    required this.name,
    required this.dateTimeListValue,
  }) : valueType = SettingsValueType.dateTimeList;

  @Id()
  int id;

  @Index(unique: true)
  String name;

  /// Indicate settings value type.
  @EnumValue()
  SettingsValueType valueType;

  String? stringValue;
  int? intValue;
  double? doubleValue;
  bool? boolValue;
  DateTime? dateTimeValue;
  List<String>? stringListValue;
  List<int>? intListValue;
  List<double>? doubleListValue;
  List<bool>? boolListValue;
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
