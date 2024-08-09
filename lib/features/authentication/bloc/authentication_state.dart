part of 'authentication_bloc.dart';

/// Status of authentication.
enum AuthenticationStatus {
  /// Initial state
  initial,

  /// Fetching hash data that need to use in login process.
  fetchingHash,

  /// After got the form hash.
  gotHash,

  /// Polling login request.
  loggingIn,

  /// Login success.
  success,

  /// Login failed.
  failure,
}

/// State of authentication.
///
/// Carrying all current logged user info and login status.
@MappableClass()
final class AuthenticationState with AuthenticationStateMappable {
  /// Constructor.
  const AuthenticationState({
    this.status = AuthenticationStatus.initial,
    this.loginHash,
    this.loginException,
  });

  /// Status of authentication.
  final AuthenticationStatus status;

  /// The login hash used to login.
  ///
  /// Useless unless is going to login.
  final LoginHash? loginHash;

  /// Exception happened in login.
  final LoginException? loginException;
}
