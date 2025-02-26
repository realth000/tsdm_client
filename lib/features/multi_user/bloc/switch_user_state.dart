part of 'switch_user_bloc.dart';

/// Basic state of switch user bloc.
@MappableClass()
sealed class SwitchUserBaseState with SwitchUserBaseStateMappable {
  /// Constructor.
  const SwitchUserBaseState();
}

/// Initial state.
@MappableClass()
final class SwitchUserInitial extends SwitchUserBaseState with SwitchUserInitialMappable {
  /// Constructor.
  const SwitchUserInitial();
}

/// Loading state.
@MappableClass()
final class SwitchUserLoading extends SwitchUserBaseState with SwitchUserLoadingMappable {
  /// Constructor.
  const SwitchUserLoading();
}

/// Success state.
@MappableClass()
final class SwitchUserSuccess extends SwitchUserBaseState with SwitchUserSuccessMappable {
  /// Constructor.
  const SwitchUserSuccess();
}

/// Failure state.
@MappableClass()
final class SwitchUserFailure extends SwitchUserBaseState with SwitchUserFailureMappable {
  /// Constructor.
  const SwitchUserFailure(this.reason);

  /// Why failed.
  final AppException reason;
}
