part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileLoadRequested extends ProfileEvent {}

final class ProfileRefreshRequested extends ProfileEvent {}

final class ProfileLogoutRequested extends ProfileEvent {}
