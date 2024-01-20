part of 'authentication_bloc.dart';

enum AuthenticationStatus {
  initial,

  /// Fetching hash data that need to use in login process.
  fetchingHash,

  //
  gotHash,

  /// Polling login request.
  loggingIn,

  /// Login success.
  success,

  /// Login failed.
  failed,
}

final class AuthenticationState extends Equatable {
  const AuthenticationState({
    this.status = AuthenticationStatus.initial,
    this.loginHash,
    this.loginException,
  });

  final AuthenticationStatus status;

  final LoginHash? loginHash;

  final LoginException? loginException;

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
