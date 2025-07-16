part of 'models.dart';

/// Base class of all root location change events.
@MappableClass()
sealed class RootLocationEvent with RootLocationEventMappable {
  /// Constructor.
  const RootLocationEvent();
}

/// Entered (or say pushed) a new page with path [path].
@MappableClass()
final class RootLocationEventEnter extends RootLocationEvent with RootLocationEventEnterMappable {
  /// Constructor.
  const RootLocationEventEnter(this.path);

  /// Path of page entered.
  final String path;
}

/// Leaved (or say popped) a new page with path [path].
///
/// When this event is triggered, page at [path] is already popped.
@MappableClass()
final class RootLocationEventLeave extends RootLocationEvent with RootLocationEventLeaveMappable {
  /// Constructor.
  const RootLocationEventLeave(this.path);

  /// Path of page entered.
  final String path;
}

/// About to leave the last page in location.
///
/// Use this event to let the cubit knows: The last page is going to pop.
///
/// When this event is triggered, it does not mean the last page is already popped, only a request to trigger leave
/// page checking logic for the cubit.
@MappableClass()
final class RootLocationEventLeavingLast extends RootLocationEvent with RootLocationEventLeavingLastMappable {
  /// Constructor.
  const RootLocationEventLeavingLast();
}
