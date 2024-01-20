import 'package:equatable/equatable.dart';

class LoginHash extends Equatable {
  const LoginHash({
    required this.formHash,
    required this.loginHash,
  });

  final String formHash;
  final String loginHash;

  @override
  List<Object?> get props => [formHash, loginHash];
}
