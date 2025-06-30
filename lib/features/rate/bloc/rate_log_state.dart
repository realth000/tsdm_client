part of 'rate_log_cubit.dart';

/// Status of rate log.
enum RateLogStatus {
  /// Initial state.
  initial,

  /// Fetching rate log.
  loading,

  /// Have data.
  success,

  /// Failed to fetch.
  failure,
}

/// State of rate log.
@MappableClass()
final class RateLogState with RateLogStateMappable {
  /// Constructor.
  const RateLogState({
    this.status = RateLogStatus.initial,
    this.accumulatedLogItems = const [],
    this.logItems = const [],
  });

  /// Current status.
  final RateLogStatus status;

  /// All fetched rate log.
  final List<RateLogItem> logItems;

  /// Log items accumulated adjacent same items.
  final List<RateLogAccumulatedItem> accumulatedLogItems;
}
