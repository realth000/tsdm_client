part of 'edit_avatar_bloc.dart';

/// Base class of all events on [EditAvatarBloc].
@MappableClass()
sealed class EditAvatarEvent with EditAvatarEventMappable {
  /// Constructor.
  const EditAvatarEvent();
}

/// Load the edit avatar page info.
@MappableClass()
final class EditAvatarLoadInfoRequested extends EditAvatarEvent with EditAvatarLoadInfoRequestedMappable {
  /// Constructor.
  const EditAvatarLoadInfoRequested();
}

/// Upload a new avatar url to server.
@MappableClass()
final class EditAvatarUploadRequested extends EditAvatarEvent with EditAvatarUploadRequestedMappable {
  /// Constructor.
  const EditAvatarUploadRequested({required this.avatarUrl, required this.formHash});

  /// Url of the new avatar.
  final String avatarUrl;

  /// Form hash used to upload.
  final String formHash;
}
