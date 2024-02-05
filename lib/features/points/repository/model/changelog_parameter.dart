/// Points value change types.
enum IncomeType {
  /// Outcome, points decreased.
  outcome(-1),

  /// Do not limit the search this type.
  unlimited(0),

  /// Income, points increased.
  income(1);

  const IncomeType(this.value);

  /// Value when used in [ChangelogParameter].
  final int value;
}

/// Query parameters used in log request.
final class ChangelogParameter {
  /// Constructor.
  const ChangelogParameter({
    required this.extType,
    required this.startTime,
    required this.endTime,
    required this.income,
    required this.operation,
    required this.pageNumer,
  });

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
  final IncomeType income;

  /// Operation type.
  final String operation;

  /// Result page number;
  final int pageNumer;

  @override
  String toString() {
    return '&exttype=$extType&income=${income.value}&optype=$operation&'
        'starttime=$startTime&endtime=$endTime';
  }
}
