part of 'rate_bloc.dart';

sealed class RateEvent extends Equatable {
  const RateEvent();

  @override
  List<Object?> get props => [];
}

final class RateFetchInfoRequested extends RateEvent {
  const RateFetchInfoRequested({
    required this.pid,
    required this.rateAction,
  }) : super();

  final String pid;
  final String rateAction;

  @override
  List<Object?> get props => [pid, rateAction];
}

final class RateRateRequested extends RateEvent {
  const RateRateRequested(this.rateInfo) : super();
  final Map<String, String> rateInfo;

  @override
  List<Object?> get props => [rateInfo];
}
