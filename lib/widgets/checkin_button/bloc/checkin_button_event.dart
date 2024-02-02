part of 'checkin_button_bloc.dart';

/// Event of checkin.
sealed class CheckinButtonEvent {
  /// Constructor.
  const CheckinButtonEvent();
}

/// User required to checkin.
final class CheckinButtonRequested extends CheckinButtonEvent {
  /// Constructor.
  const CheckinButtonRequested() : super();
}

/// Auth status changed.
///
/// Triggered by [CheckinButtonBloc].
final class _CheckinButtonAuthChanged extends CheckinButtonEvent {
  /// Constructor.
  const _CheckinButtonAuthChanged({required this.authed}) : super();

  /// Latest auth status.
  final bool authed;
}
