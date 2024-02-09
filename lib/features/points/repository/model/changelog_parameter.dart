import 'package:equatable/equatable.dart';

/// Query parameters used in log request.
final class ChangelogParameter extends Equatable {
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

  /// Copy with.
  ChangelogParameter copyWith({
    String? extType,
    String? startTime,
    String? endTime,
    String? incomeType,
    String? operation,
    int? pageNumber,
  }) {
    return ChangelogParameter(
      extType: extType ?? this.extType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      changeType: incomeType ?? this.changeType,
      operation: operation ?? this.operation,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }

  @override
  String toString() {
    return '&exttype=$extType&income=$changeType&optype=$operation&'
        'starttime=$startTime&endtime=$endTime&page=$pageNumber';
  }

  @override
  List<Object?> get props => [
        extType,
        startTime,
        endTime,
        changeType,
        operation,
        pageNumber,
      ];
}
