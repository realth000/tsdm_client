part of 'rate_bloc.dart';

/// Status of rating.
enum RateStatus {
  /// Initial.
  initial,
  /// Currently is fetching rate info.
  ///
  /// Similar to [initial] state, the UI should be blocked
  /// until current status finished.
  fetchingInfo,
  /// Fetched rate info and waiting for user to rate.
  gotInfo,
  /// Doing the rate action.
  rating,
  /// Rate succeed.
  success,
  /// Rate failed.
  failed;

  /// Is loading data.
  ///
  /// Should block the UI (maybe in different ways) in this state.
  bool isLoading() =>
      this == RateStatus.initial ||
      this == RateStatus.fetchingInfo ||
      this == RateStatus.rating;
}

/// State of rate.
final class RateState extends Equatable {
  /// Constructor.
  const RateState({
    this.status = RateStatus.initial,
    this.info,
    this.failedReason,
    this.shouldRetry = true,
  });

  /// Status.
  final RateStatus status;

  /// Info to show in rate.
  ///
  /// These info are inside the floating window if using
  /// browser.
  final RateWindowInfo? info;

  /// Why failed to rate.
  final String? failedReason;

  /// Flag indicating whether should let user have chance to retry.
  ///
  /// * When set to true, do NOT navigate page back because the
  ///   failure of rate is some occationaly error, such as network
  ///   connection failed and we should keep the rate info and
  ///   wait for the user to retry.
  /// * When set to false, it means the failure is some reason
  ///   definitely happen in rate, such as the user tried to rate
  ///   a post published by user self, which is not allowed. So
  ///   just redirect back.
  final bool? shouldRetry;

  /// Copy with.
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
