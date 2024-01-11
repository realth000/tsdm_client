part of 'profile_bloc.dart';

enum ProfileStatus {
  initial,
  loading,
  needLogin,

  /// Processing logout action
  logout,
  success,
  failed,
}

/// State of profile page of the app.
class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.userProfile,
    this.failedToLogoutReason,
  });

  final ProfileStatus status;

  final UserProfile? userProfile;

  /// An exception representing that the former logout action is failed.
  /// This is not an separate state because we need to record extra failed reason and also though logout failed the
  /// page content is as same as [ProfileStatus.success].
  final Exception? failedToLogoutReason;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? userProfile,
    Exception? failedToLogoutReason,
  }) {
    return ProfileState(
      status: status ?? this.status,
      userProfile: userProfile ?? this.userProfile,
      failedToLogoutReason:
          failedToLogoutReason, // This argument should be cleaned if not set.
    );
  }

  @override
  List<Object?> get props => [status, userProfile];
}
