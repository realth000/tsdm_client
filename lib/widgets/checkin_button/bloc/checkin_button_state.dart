part of 'checkin_button_bloc.dart';

/// State of checkin button.
@MappableClass()
sealed class CheckinButtonState with CheckinButtonStateMappable {
  const CheckinButtonState();
}

/// Initial state.
@MappableClass()
final class CheckinButtonInitial extends CheckinButtonState
    with CheckinButtonInitialMappable {
  /// Constructor.
  const CheckinButtonInitial() : super();
}

/// Loading data: checking in.
@MappableClass()
final class CheckinButtonLoading extends CheckinButtonState
    with CheckinButtonLoadingMappable {
  /// Constructor.
  const CheckinButtonLoading() : super();
}

/// Need to login to checkin.
@MappableClass()
final class CheckinButtonNeedLogin extends CheckinButtonState
    with CheckinButtonNeedLoginMappable {
  /// Constructor.
  const CheckinButtonNeedLogin() : super();
}

/// Checkin failed.
@MappableClass()
final class CheckinButtonFailed extends CheckinButtonState
    with CheckinButtonFailedMappable {
  /// Constructor.
  const CheckinButtonFailed(this.result) : super();

  /// Result of checkin.
  final CheckinResult result;
}

/// Checkin succeed.
@MappableClass()
final class CheckinButtonSuccess extends CheckinButtonState
    with CheckinButtonSuccessMappable {
  /// Constructor.
  const CheckinButtonSuccess(this.message) : super();

  /// Error text.
  final String message;
}
