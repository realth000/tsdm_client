part of 'rate_bloc.dart';

/// Event of rate.
sealed class RateEvent extends Equatable {
  const RateEvent();

  @override
  List<Object?> get props => [];
}

/// Request to fetch rate info.
///
/// This should be triggered once opened the rate page.
/// Before this event complete, user should be unable to interact with the page.
final class RateFetchInfoRequested extends RateEvent {
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
final class RateRateRequested extends RateEvent {
  /// Constructor.
  const RateRateRequested(this.rateInfo) : super();

  /// Rate detail info for each field user can rate.
  final Map<String, String> rateInfo;

  @override
  List<Object?> get props => [rateInfo];
}
