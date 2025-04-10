part of 'edit_avatar_bloc.dart';

/// Current status of [EditAvatarState].
enum EditAvatarStatus {
  /// Initial state.
  initial,

  /// Loading edit avatar page information.
  loading,

  /// Uploading the result: new avatar url.
  uploading,

  /// Waiting for user to upload avatar.
  waitingForUpload,

  /// Successfully uploaded image url.
  success,

  /// Failed to load avatar edit page or upload new image url to server.
  failure,
}

/// Base state of edit avatar bloc.
@MappableClass()
final class EditAvatarState with EditAvatarStateMappable {
  /// Constructor.
  const EditAvatarState({this.status = EditAvatarStatus.initial, this.avatarUrl, this.draftUrl, this.formHash});

  /// Current status.
  final EditAvatarStatus status;

  /// The external url of avatar.
  final String? avatarUrl;

  /// The url user inputted but not submitted to server yet, because of a network error or something else...
  final String? draftUrl;

  /// The used form hash.
  final String? formHash;
}
