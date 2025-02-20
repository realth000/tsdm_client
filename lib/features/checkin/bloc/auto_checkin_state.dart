part of 'auto_checkin_bloc.dart';

/// Base class for the state of auto checkin bloc.
@MappableClass()
sealed class AutoCheckinState with AutoCheckinStateMappable {
  /// Constructor.
  const AutoCheckinState();
}

/// Initial state
@MappableClass()
final class AutoCheckinStateInitial extends AutoCheckinState with AutoCheckinStateInitialMappable {
  /// Constructor.
  const AutoCheckinStateInitial();
}

/// Preparing state.
@MappableClass()
final class AutoCheckinStatePreparing extends AutoCheckinState with AutoCheckinStatePreparingMappable {
  /// Constructor.
  const AutoCheckinStatePreparing();
}

/// Running the checkin progress.
///
/// Keep in this state if any user is in checking in.
/// Only leave this state when all users finished checkin progress, no matter
/// end with success or failure.
@MappableClass()
final class AutoCheckinStateLoading extends AutoCheckinState with AutoCheckinStateLoadingMappable {
  /// Constructor.
  const AutoCheckinStateLoading(this.info);

  /// Construct a instance with starting point values.
  factory AutoCheckinStateLoading.start(AutoCheckinInfo info) => AutoCheckinStateLoading(info);

  /// Current checkin info.
  final AutoCheckinInfo info;
}

/// All users' checkin progress were finished.
///
/// Store the result state because user may want to check it.
@MappableClass()
final class AutoCheckinStateFinished extends AutoCheckinState with AutoCheckinStateFinishedMappable {
  /// Constructor.
  const AutoCheckinStateFinished({required this.succeeded, required this.failed});

  /// All users run the checkin progress successfully.
  final List<(UserLoginInfo, CheckinResult)> succeeded;

  /// All users run the checkin progress but ended with failure.
  final List<(UserLoginInfo, CheckinResult)> failed;
}
