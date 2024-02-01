part of 'authentication_bloc.dart';

/// Event of authentication.
sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

/// Call this event to fetch hash data required in login process before login.
final class AuthenticationFetchLoginHashRequested extends AuthenticationEvent {}

/// User request to login with user credential.
final class AuthenticationLoginRequested extends AuthenticationEvent {
  /// Constructor.
  const AuthenticationLoginRequested(this.userCredential) : super();

  /// User credential.
  final UserCredential userCredential;
}
