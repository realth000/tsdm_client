part of 'checkin_button_bloc.dart';

/// State of checkin button.
sealed class CheckinButtonState extends Equatable {
  const CheckinButtonState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
final class CheckinButtonInitial extends CheckinButtonState {
  /// Constructor.
  const CheckinButtonInitial() : super();
}

/// Loading data: checking in.
final class CheckinButtonLoading extends CheckinButtonState {
  /// Constructor.
  const CheckinButtonLoading() : super();
}

/// Need to login to checkin.
final class CheckinButtonNeedLogin extends CheckinButtonState {
  /// Constructor.
  const CheckinButtonNeedLogin() : super();
}

/// Checkin failed.
final class CheckinButtonFailed extends CheckinButtonState {
  /// Constructor.
  const CheckinButtonFailed(this.result) : super();

  /// Result of checkin.
  final CheckinResult result;
}

/// Checkin succeed.
final class CheckinButtonSuccess extends CheckinButtonState {
  /// Constructor.
  const CheckinButtonSuccess(this.message) : super();

  /// Error text.
  final String message;
}
