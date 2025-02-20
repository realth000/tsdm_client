part of 'checkin_bloc.dart';

/// State of checkin button.
@MappableClass()
sealed class CheckinState with CheckinStateMappable {
  const CheckinState();
}

/// Initial state.
@MappableClass()
final class CheckinStateInitial extends CheckinState with CheckinStateInitialMappable {
  /// Constructor.
  const CheckinStateInitial() : super();
}

/// Loading data: checking in.
@MappableClass()
final class CheckinStateLoading extends CheckinState with CheckinStateLoadingMappable {
  /// Constructor.
  const CheckinStateLoading() : super();
}

/// Need to login to checkin.
@MappableClass()
final class CheckinStateNeedLogin extends CheckinState with CheckinStateNeedLoginMappable {
  /// Constructor.
  const CheckinStateNeedLogin() : super();
}

/// Checkin failed.
@MappableClass()
final class CheckinStateFailed extends CheckinState with CheckinStateFailedMappable {
  /// Constructor.
  const CheckinStateFailed(this.result) : super();

  /// Result of checkin.
  final CheckinResult result;
}

/// Checkin succeed.
@MappableClass()
final class CheckinStateSuccess extends CheckinState with CheckinStateSuccessMappable {
  /// Constructor.
  const CheckinStateSuccess(this.message) : super();

  /// Error text.
  final String message;
}
