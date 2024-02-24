part of 'checkin_button_bloc.dart';

/// Event of checkin.
@MappableClass()
sealed class CheckinButtonEvent with CheckinButtonEventMappable {
  /// Constructor.
  const CheckinButtonEvent();
}

/// User required to checkin.
@MappableClass()
final class CheckinButtonRequested extends CheckinButtonEvent
    with CheckinButtonRequestedMappable {
  /// Constructor.
  const CheckinButtonRequested() : super();
}

/// Auth status changed.
///
/// Triggered by [CheckinButtonBloc].
///
/// Passive event.
@MappableClass()
final class CheckinButtonAuthChanged extends CheckinButtonEvent
    with CheckinButtonAuthChangedMappable {
  /// Constructor.
  const CheckinButtonAuthChanged({required this.authed}) : super();

  /// Latest auth status.
  final bool authed;
}
