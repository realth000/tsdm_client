part of 'rate_bloc.dart';

enum RateStatus {
  initial,
  fetchingInfo,
  gotInfo,
  rating,
  success,
  failed;

  bool isLoading() =>
      this == RateStatus.initial ||
      this == RateStatus.fetchingInfo ||
      this == RateStatus.rating;
}

final class RateState extends Equatable {
  const RateState({
    this.status = RateStatus.initial,
    this.info,
    this.failedReason,
    this.shouldRetry = true,
  });

  final RateStatus status;

  final RateWindowInfo? info;

  final String? failedReason;

  final bool? shouldRetry;

  RateState copyWith({
    RateStatus? status,
    RateWindowInfo? info,
    String? failedReason,
    bool? shouldRetry,
  }) {
    return RateState(
      status: status ?? this.status,
      info: info ?? this.info,
      failedReason: failedReason ?? this.failedReason,
      shouldRetry: shouldRetry ?? this.shouldRetry,
    );
  }

  @override
  List<Object?> get props => [
        status,
        info,
        failedReason,
        shouldRetry,
      ];
}
