part of 'models.dart';

/// Points type.
///
/// Contains type readable [name] and parameter [extType] used in parameters.
@MappableClass()
class ChangelogPointsType with ChangelogPointsTypeMappable {
  /// Constructor.
  const ChangelogPointsType({required this.name, required this.extType});

  /// Human readable name.
  ///
  /// e.g. 威望
  final String name;

  /// Parameter used in filter query.
  ///
  /// e.g. 1
  final String extType;
}

/// Changelog event operation type.
///
/// Contains a human readable [name] and an [operation] name used in query
/// filter parameters.
@MappableClass()
final class ChangelogOperationType with ChangelogOperationTypeMappable {
  /// Constructor.
  const ChangelogOperationType({required this.name, required this.operation});

  /// Human readable name.
  ///
  /// e.g. 转账接收
  final String name;

  /// Operation name used in query filter parameters.
  ///
  /// e.g. RCV
  final String operation;
}

/// Changelog event points change type.
///
/// Contains a human readable [name] and an [changeType] name used in query
/// filter parameters.
@MappableClass()
final class ChangelogChangeType with ChangelogChangeTypeMappable {
  /// Constructor.
  const ChangelogChangeType({required this.name, required this.changeType});

  /// Human readable name.
  ///
  /// e.g. 收入
  final String name;

  /// Operation name used in query filter parameters.
  ///
  /// e.g. 1
  final String changeType;
}

/// Represent all parameters that user can use to make a query.
@MappableClass()
class ChangelogAllParameters with ChangelogAllParametersMappable {
  /// Constructor.
  const ChangelogAllParameters({
    required this.extTypeList,
    required this.operationTypeList,
    required this.changeTypeList,
  });

  /// Construct an empty parameter.
  const ChangelogAllParameters.empty()
    : extTypeList = const [],
      operationTypeList = const [],
      changeTypeList = const [];

  /// All available points type to filter.
  final List<ChangelogPointsType> extTypeList;

  /// All available operation type to filter.
  final List<ChangelogOperationType> operationTypeList;

  /// All available change types.
  final List<ChangelogChangeType> changeTypeList;
}
