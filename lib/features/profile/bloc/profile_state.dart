part of 'profile_bloc.dart';

/// Status of profile page.
enum ProfileStatus {
  /// Initial status.
  initial,

  /// Loading data before user can login.
  loading,

  /// Loaded the required data and waiting for user to login.
  needLogin,

  /// Processing logout action
  logout,

  /// Login or logout succeed.
  success,

  /// Login or logout failed.
  failed,
}

/// State of profile page of the app.
class ProfileState extends Equatable {
  /// Constructor.
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.username,
    this.uid,
    this.userProfile,
    this.failedToLogoutReason,
  });

  /// Status.
  final ProfileStatus status;

  /// Username of the profile page.
  final String? username;

  /// Uid of the profile page.
  final String? uid;

  /// Profile data to show in page.
  final UserProfile? userProfile;

  /// An exception representing that the former logout action is failed.
  /// This is not an separate state because we need to record extra failed
  /// reason and also though logout failed the
  /// page content is as same as [ProfileStatus.success].
  final Exception? failedToLogoutReason;

  /// Copy with.
  ProfileState copyWith({
    ProfileStatus? status,
    String? username,
    String? uid,
    UserProfile? userProfile,
    Exception? failedToLogoutReason,
  }) {
    return ProfileState(
      status: status ?? this.status,
      username: username ?? this.username,
      uid: uid ?? this.uid,
      userProfile: userProfile ?? this.userProfile,
      failedToLogoutReason:
          failedToLogoutReason, // This argument should be cleaned if not set.
    );
  }

  @override
  List<Object?> get props => [
        status,
        username,
        uid,
        userProfile,
        failedToLogoutReason,
      ];
}
