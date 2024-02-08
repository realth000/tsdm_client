import 'package:equatable/equatable.dart';

/// Points value change types.
enum IncomeType {
  /// Outcome, points decreased.
  outcome(-1),

  /// Do not limit the search this type.
  all(0),

  /// Income, points increased.
  income(1);

  const IncomeType(this.value);

  /// Value when used in [ChangelogParameter].
  final int value;
}

/// Query parameters used in log request.
final class ChangelogParameter extends Equatable {
  /// Constructor.
  const ChangelogParameter({
    required this.extType,
    required this.startTime,
    required this.endTime,
    required this.incomeType,
    required this.operation,
    required this.pageNumber,
  });

  /// Construct an empty query parameter.
  const ChangelogParameter.empty()
      : extType = '',
        startTime = '',
        endTime = '',
        incomeType = IncomeType.all,
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
  final IncomeType incomeType;

  /// Operation type.
  final String operation;

  /// Result page number;
  final int pageNumber;

  /// Copy with.
  ChangelogParameter copyWith({
    String? extType,
    String? startTime,
    String? endTime,
    IncomeType? incomeType,
    String? operation,
    int? pageNumber,
  }) {
    return ChangelogParameter(
      extType: extType ?? this.extType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      incomeType: incomeType ?? this.incomeType,
      operation: operation ?? this.operation,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }

  @override
  String toString() {
    return '&exttype=$extType&income=${incomeType.value}&optype=$operation&'
        'starttime=$startTime&endtime=$endTime&page=$pageNumber';
  }

  @override
  List<Object?> get props => [
        extType,
        startTime,
        endTime,
        incomeType,
        operation,
        pageNumber,
      ];
}
