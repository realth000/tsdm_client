part of 'rate_bloc.dart';

/// Event of rate.
@MappableClass()
sealed class RateEvent with RateEventMappable {
  const RateEvent();
}

/// Request to fetch rate info.
///
/// This should be triggered once opened the rate page.
/// Before this event complete, user should be unable to interact with the page.
@MappableClass()
final class RateFetchInfoRequested extends RateEvent
    with RateFetchInfoRequestedMappable {
  /// Constructor.
  const RateFetchInfoRequested({
    required this.pid,
    required this.rateAction,
  }) : super();

  /// Post id.
  final String pid;

  /// Rate action url to do the rate.
  final String rateAction;

  @override
  List<Object?> get props => [pid, rateAction];
}

/// User requested to rate.
@MappableClass()
final class RateRateRequested extends RateEvent with RateRateRequestedMappable {
  /// Constructor.
  const RateRateRequested(this.rateInfo) : super();

  /// Rate detail info for each field user can rate.
  final Map<String, String> rateInfo;
}
