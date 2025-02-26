part of 'switch_user_bloc.dart';

/// Basic event of switch user bloc.
@MappableClass()
sealed class SwitchUserBaseEvent with SwitchUserBaseEventMappable {
  /// Constructor.
  const SwitchUserBaseEvent();
}

/// Start a switching.
@MappableClass()
final class SwitchUserStartRequested extends SwitchUserBaseEvent with SwitchUserStartRequestedMappable {
  /// Constructor.
  const SwitchUserStartRequested(this.userInfo);

  /// Info about use going to switch to.
  final UserLoginInfo userInfo;
}
