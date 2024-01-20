import 'package:equatable/equatable.dart';

/// Authenticated user.
class User extends Equatable {
  const User({
    this.username,
    this.uid,
    this.password,
    this.email,
  });

  final String? username;
  final String? uid;
  final String? password;
  final String? email;

  @override
  List<Object?> get props => [username, uid, password, email];
}
