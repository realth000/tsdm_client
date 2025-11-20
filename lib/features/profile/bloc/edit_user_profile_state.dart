part of 'edit_user_profile_bloc.dart';

/// The status.
enum EditUserProfileStatus {
  /// Initial state.
  initial,

  /// Loading current user profile.
  loading,

  /// Submitting latest user profile data.
  submitting,

  /// Load succeeded or submit succeeded.
  success,

  /// Failed to load or submit.
  failure,
}

/// The state.
@MappableClass()
final class EditUserProfileState with EditUserProfileStateMappable {
  /// Constructor.
  const EditUserProfileState({this.status = .initial, this.profile});

  /// The status.
  final EditUserProfileStatus status;

  /// Current loaded profile.
  final eup.UserProfile? profile;
}
