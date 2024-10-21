part of 'profile_bloc.dart';

/// Event of profile page.
@MappableClass()
sealed class ProfileEvent with ProfileEventMappable {
  const ProfileEvent();
}

/// Load current logged user profile if both [username] and [uid] are null.
@MappableClass()
final class ProfileLoadRequested extends ProfileEvent
    with ProfileLoadRequestedMappable {
  /// Constructor.
  const ProfileLoadRequested({
    required this.username,
    required this.uid,
  }) : super();

  /// Other user username.
  final String? username;

  /// Other user uid.
  final String? uid;
}

/// User required to refresh the profile page.
@MappableClass()
final class ProfileRefreshRequested extends ProfileEvent
    with ProfileRefreshRequestedMappable {
  /// Constructor.
  const ProfileRefreshRequested({
    required this.username,
    required this.uid,
  });

  /// Other user username.
  final String? username;

  /// Other user uid.
  final String? uid;
}

/// User required to logout.
///
/// Only available when in current logged user's profile page.
@MappableClass()
final class ProfileLogoutRequested extends ProfileEvent
    with ProfileLogoutRequestedMappable {}
