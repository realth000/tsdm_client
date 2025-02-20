import 'package:fpdart/fpdart.dart';

/// Get the inner value without wrapping following code inside brackets.
extension UnwrapExt<L, R> on Either<L, R> {
  /// Unwrap the value current [Either].
  ///
  /// Call MUST make sure not a failure before calling [unwrap] otherwise
  /// it will throw when containing error.
  R unwrap() => switch (this) {
    Left() => throw Exception('unwrap on a null value'),
    Right(:final value) => value,
  };

  /// Unwrap the error in current [Either].
  ///
  /// Call MUST make sure a failure inside before calling [unwrap] otherwise
  /// it will throw when containing value.
  L unwrapErr() => switch (this) {
    Left(:final value) => value,
    Right() => throw Exception('unwrap on a null value'),
  };
}
