part of 'authentication_bloc.dart';

/// Event of authentication.
@MappableClass()
sealed class AuthenticationEvent with AuthenticationEventMappable {
  const AuthenticationEvent();
}

/// Call this event to fetch hash data required in login process before login.
@MappableClass()
final class AuthenticationFetchLoginHashRequested extends AuthenticationEvent
    with AuthenticationFetchLoginHashRequestedMappable {}

/// User request to login with user credential.
@MappableClass()
final class AuthenticationLoginRequested extends AuthenticationEvent with AuthenticationLoginRequestedMappable {
  /// Constructor.
  const AuthenticationLoginRequested(this.userCredential) : super();

  /// User credential.
  final UserCredential userCredential;
}
