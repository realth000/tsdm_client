part of 'models.dart';

/// Query parameters used in log request.
@MappableClass()
final class ChangelogParameter with ChangelogParameterMappable {
  /// Constructor.
  const ChangelogParameter({
    required this.extType,
    required this.operation,
    required this.changeType,
    required this.startTime,
    required this.endTime,
    required this.pageNumber,
  });

  /// Construct an empty query parameter.
  const ChangelogParameter.empty()
    : extType = '',
      startTime = '',
      endTime = '',
      changeType = '',
      operation = '',
      pageNumber = 1;

  /// Points type
  ///
  /// Default: "0
  final String extType;

  /// Search start time.
  ///
  /// Format: "yyyy-MM-dd"
  ///
  /// Default: ""
  final String startTime;

  /// Search end time.
  ///
  /// Format: "yyyy-MM-dd"
  ///
  /// Default: ""
  final String endTime;

  /// Points increase/decrease.
  final String changeType;

  /// Operation type.
  final String operation;

  /// Result page number;
  final int pageNumber;

  @override
  String toString() {
    return '&exttype=$extType&income=$changeType&optype=$operation&'
        'starttime=$startTime&endtime=$endTime&page=$pageNumber';
  }
}
