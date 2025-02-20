part of 'init_cubit.dart';

/// Empty state placeholder.
@MappableClass()
final class InitState with InitStateMappable {
  /// Constructor.
  const InitState({this.v0LegacyDataDeleted = false});

  /// Flag indicating legacy data used before v1.0 found and deleted.
  ///
  /// Those data are not usable because we migrated our storage database from
  /// isar to drift in version 1.0.
  ///
  /// So delete those data and also image cache.
  final bool v0LegacyDataDeleted;
}
