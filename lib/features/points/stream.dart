import 'dart:async';

/// Stream of events of user points changes.
///
/// User points may change after submitting actions, those changes are passed through the stream.
final StreamController<String> pointsChangesStream = StreamController<String>.broadcast();
