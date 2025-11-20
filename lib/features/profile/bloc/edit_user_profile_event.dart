part of 'edit_user_profile_bloc.dart';

/// The base event.
@MappableClass()
sealed class EditUserProfileEvent with EditUserProfileEventMappable {
  /// Constructor.
  const EditUserProfileEvent();
}

/// Load current user's profile.
@MappableClass()
final class EditUserProfileLoadProfileRequested extends EditUserProfileEvent
    with EditUserProfileLoadProfileRequestedMappable {
  /// Constructor.
  const EditUserProfileLoadProfileRequested();
}

/// Submit a new user profile state to server.
@MappableClass()
final class EditUserProfileSubmitRequested extends EditUserProfileEvent with EditUserProfileSubmitRequestedMappable {
  /// Constructor.
  const EditUserProfileSubmitRequested(this.profile);

  /// User profile to submit.
  final eup.UserProfile profile;
}

/// Save profile in state.
@MappableClass()
final class EditUserProfileSaveProfileRequested extends EditUserProfileEvent
    with EditUserProfileSaveProfileRequestedMappable {
  /// Constructor.
  const EditUserProfileSaveProfileRequested(this.profile);

  /// User profile to save in state.
  final eup.UserProfile profile;
}

/// Upload profile to server.
@MappableClass()
final class EditUserProfileUploadProfileRequested extends EditUserProfileEvent
    with EditUserProfileUploadProfileRequestedMappable {
  /// Constructor.
  const EditUserProfileUploadProfileRequested(this.profile);

  /// User profile to save in state.
  final eup.UserProfile profile;
}
