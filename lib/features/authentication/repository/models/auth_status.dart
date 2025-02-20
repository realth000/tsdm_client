part of 'models.dart';

/// Base class of authentication status.
///
/// All derived models are used as auth status update reported from auth repo.
@MappableClass()
sealed class AuthStatus with AuthStatusMappable {
  /// Constructor.
  const AuthStatus();
}

/// Unknown auth state.
///
/// Intend to be not used.
@MappableClass()
final class AuthStatusUnknown extends AuthStatus with AuthStatusUnknownMappable {
  /// Constructor.
  const AuthStatusUnknown();
}

/// Doing an authenticate action.
///
/// Current state is not stable, performing user login and should block most
/// other actions.
@MappableClass()
final class AuthStatusLoading extends AuthStatus with AuthStatusLoadingMappable {
  /// Constructor.
  const AuthStatusLoading();
}

/// Not authed.
@MappableClass()
final class AuthStatusNotAuthed extends AuthStatus with AuthStatusNotAuthedMappable {
  /// Constructor.
  const AuthStatusNotAuthed();
}

/// Authenticated.
///
/// Carrying auth user info.
@MappableClass()
final class AuthStatusAuthed extends AuthStatus with AuthStatusAuthedMappable {
  /// Constructor.
  const AuthStatusAuthed(this.userInfo);

  /// Carried user info.
  final UserLoginInfo userInfo;
}
