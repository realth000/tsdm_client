part of 'checkin_button_bloc.dart';

sealed class CheckinButtonEvent {
  const CheckinButtonEvent();
}

final class CheckinButtonRequested extends CheckinButtonEvent {
  const CheckinButtonRequested() : super();
}

final class _CheckinButtonAuthChanged extends CheckinButtonEvent {
  const _CheckinButtonAuthChanged({required this.authed}) : super();
  final bool authed;
}
