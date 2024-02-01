import 'package:equatable/equatable.dart';

/// A group of login hash used in login or logout progress.
class LoginHash extends Equatable {
  /// Constructor.
  const LoginHash({
    required this.formHash,
    required this.loginHash,
  });

  /// Form hash.
  final String formHash;

  /// Login hash.
  ///
  /// Seems not used.
  final String loginHash;

  @override
  List<Object?> get props => [formHash, loginHash];
}
