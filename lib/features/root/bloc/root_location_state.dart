part of 'root_location_cubit.dart';

/// The state of root location cubit.
@MappableClass()
final class RootLocationState with RootLocationStateMappable {
  /// Constructor.
  const RootLocationState({this.lastRequestLeavePageTime, this.locations = const []});

  /// Date time when last request leave page, like an ID of different pop page requests.
  ///
  /// Use this field to identity different pop page requests and trigger the listener which handles double-press
  /// exit app feature.
  ///
  /// Literally it is not semantic, but ok.
  final DateTime? lastRequestLeavePageTime;

  /// Current locations.
  ///
  /// Nested route paths.
  final List<String> locations;
}
