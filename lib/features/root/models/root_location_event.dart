part of 'models.dart';

/// Base class of all root location change events.
@MappableClass()
sealed class RootLocationEvent with RootLocationEventMappable {
  /// Constructor.
  const RootLocationEvent();
}

/// Entered (or say pushed) a new page with path [path].
@MappableClass()
final class RootLocationEventEnter extends RootLocationEvent
    with RootLocationEventEnterMappable {
  /// Constructor.
  const RootLocationEventEnter(this.path);

  /// Path of page entered.
  final String path;
}

/// Leaved (or say popped) a new page with path [path].
@MappableClass()
final class RootLocationEventLeave extends RootLocationEvent
    with RootLocationEventLeaveMappable {
  /// Constructor.
  const RootLocationEventLeave(this.path);

  /// Path of page entered.
  final String path;
}
