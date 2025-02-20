part of 'models.dart';

/// A group of login hash used in login or logout progress.
@MappableClass()
class LoginHash with LoginHashMappable {
  /// Constructor.
  const LoginHash({required this.formHash, required this.loginHash});

  /// Form hash.
  final String formHash;

  /// Login hash.
  ///
  /// Seems not used.
  final String loginHash;
}
