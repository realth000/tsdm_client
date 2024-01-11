part of 'checkin_button_bloc.dart';

sealed class CheckinButtonState {
  const CheckinButtonState();
}

final class CheckinButtonInitial extends CheckinButtonState {
  const CheckinButtonInitial() : super();
}

final class CheckinButtonLoading extends CheckinButtonState {
  const CheckinButtonLoading() : super();
}

final class CheckinButtonNeedLogin extends CheckinButtonState {
  const CheckinButtonNeedLogin() : super();
}

final class CheckinButtonFailed extends CheckinButtonState {
  const CheckinButtonFailed(this.result) : super();

  final CheckinResult result;
}

final class CheckinButtonSuccess extends CheckinButtonState {
  const CheckinButtonSuccess(this.message) : super();
  final String message;
}
