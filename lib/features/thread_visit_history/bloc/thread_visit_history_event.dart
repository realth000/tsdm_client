part of 'thread_visit_history_bloc.dart';

/// Base event.
@MappableClass()
sealed class ThreadVisitHistoryEvent with ThreadVisitHistoryEventMappable {
  /// Constructor.
  const ThreadVisitHistoryEvent();
}

/// Fetch all data.
@MappableClass()
final class ThreadVisitHistoryFetchAllRequested extends ThreadVisitHistoryEvent
    with ThreadVisitHistoryFetchAllRequestedMappable {
  /// Constructor.
  const ThreadVisitHistoryFetchAllRequested();
}

/// Fetch all history on given user's [uid].
@MappableClass()
final class ThreadVisitHistoryFetchByUserRequested
    extends ThreadVisitHistoryEvent
    with ThreadVisitHistoryFetchByUserRequestedMappable {
  /// Constructor.
  const ThreadVisitHistoryFetchByUserRequested(this.uid);

  /// Id of user to fetch history data.
  final int uid;
}

/// Save visit history to storage.
@MappableClass()
final class ThreadVisitHistoryUpdateRequested extends ThreadVisitHistoryEvent
    with ThreadVisitHistoryUpdateRequestedMappable {
  /// Constructor.
  const ThreadVisitHistoryUpdateRequested(this.history);

  /// History to save.
  final ThreadVisitHistoryModel history;
}

/// Delete all visit history.
@MappableClass()
final class ThreadVisitHistoryClearRequested extends ThreadVisitHistoryEvent
    with ThreadVisitHistoryClearRequestedMappable {
  /// Constructor.
  const ThreadVisitHistoryClearRequested();
}
