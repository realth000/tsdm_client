part of 'authentication_bloc.dart';

sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

/// Call this event to fetch hash data required in login process before login.
final class AuthenticationFetchLoginHashRequested extends AuthenticationEvent {}

final class AuthenticationLoginRequested extends AuthenticationEvent {
  const AuthenticationLoginRequested(this.userCredential) : super();
  final UserCredential userCredential;
}
