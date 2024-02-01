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
  failed,
}

/// State of authentication.
///
/// Carrying all current logged user info and login status.
final class AuthenticationState extends Equatable {
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

  /// Copy with.
  AuthenticationState copyWith({
    AuthenticationStatus? status,
    LoginHash? loginHash,
    LoginException? loginException,
  }) {
    return AuthenticationState(
      status: status ?? this.status,
      loginHash: loginHash ?? this.loginHash,
      loginException: loginException ?? this.loginException,
    );
  }

  @override
  List<Object?> get props => [status];
}
