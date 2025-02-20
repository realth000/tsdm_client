part of 'checkin_bloc.dart';

/// Event of checkin.
@MappableClass()
sealed class CheckinEvent with CheckinEventMappable {
  /// Constructor.
  const CheckinEvent();
}

/// User required to checkin.
@MappableClass()
final class CheckinRequested extends CheckinEvent with CheckinRequestedMappable {
  /// Constructor.
  const CheckinRequested() : super();
}

/// Auth status changed.
///
/// Triggered by [CheckinBloc].
///
/// Passive event.
@MappableClass()
final class CheckinAuthChanged extends CheckinEvent with CheckinAuthChangedMappable {
  /// Constructor.
  const CheckinAuthChanged({required this.authed}) : super();

  /// Latest auth status.
  final bool authed;
}
