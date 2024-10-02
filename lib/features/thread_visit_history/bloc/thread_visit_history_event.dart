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

/// Delete an unique thread visit history.
///
/// Find it by user's id [uid] and thread's id [tid].
@MappableClass()
final class ThreadVisitHistoryDeleteRecordRequested
    extends ThreadVisitHistoryEvent
    with ThreadVisitHistoryDeleteRecordRequestedMappable {
  /// Constructor.
  const ThreadVisitHistoryDeleteRecordRequested({
    required this.uid,
    required this.tid,
  });

  /// User id to locate the unique history item.
  final int uid;

  /// Thread id to locate the unique history item.
  final int tid;
}

/// Delete all visit history.
@MappableClass()
final class ThreadVisitHistoryClearRequested extends ThreadVisitHistoryEvent
    with ThreadVisitHistoryClearRequestedMappable {
  /// Constructor.
  const ThreadVisitHistoryClearRequested();
}
