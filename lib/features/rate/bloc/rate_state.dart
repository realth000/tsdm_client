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
  });

  final RateStatus status;

  final RateWindowInfo? info;

  final String? failedReason;

  RateState copyWith({
    RateStatus? status,
    RateWindowInfo? info,
    String? failedReason,
  }) {
    return RateState(
      status: status ?? this.status,
      info: info ?? this.info,
      failedReason: failedReason ?? this.failedReason,
    );
  }

  @override
  List<Object?> get props => [status, info, failedReason];
}
