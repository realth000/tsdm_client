part of 'profile_bloc.dart';

/// Event of profile page.
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load current logged user profile if both [username] and [uid] are null.
final class ProfileLoadRequested extends ProfileEvent {
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
final class ProfileRefreshRequested extends ProfileEvent {}

/// User required to logout.
///
/// Only available when in current logged user's profile page.
final class ProfileLogoutRequested extends ProfileEvent {}
