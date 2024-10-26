part of 'root_cubit.dart';

/// State of root cubit.
@MappableClass()
final class RootState with RootStateMappable {
  /// Constructor.
  const RootState({
    this.showBottomAutoCheckinStatus = false,
  });

  /// Flag controlling visibility of auto checkin status in the bottom of the
  /// page.
  final bool showBottomAutoCheckinStatus;
}
