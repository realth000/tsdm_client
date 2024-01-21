part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load current logged user profile if both [username] and [uid] are null.
final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested({
    required this.username,
    required this.uid,
  }) : super();

  /// Other user username.
  final String? username;

  /// Other user uid.
  final String? uid;
}

final class ProfileRefreshRequested extends ProfileEvent {}

final class ProfileLogoutRequested extends ProfileEvent {}
