part of 'thread_visit_history_bloc.dart';

/// Status of thread visit history feature.
enum ThreadVisitHistoryStatus {
  /// Initial
  initial,

  /// Loading data from storage.
  loadingData,

  /// Doing action that write to the storage.
  ///
  /// Like delete all history for some user.
  savingData,

  /// Action succeeded, data is available.
  success,

  /// Failed to do an action.
  failure,
}

/// State of thread visit history feature.
///
/// Stores full history saved in db.
@MappableClass()
final class ThreadVisitHistoryState with ThreadVisitHistoryStateMappable, LoggerMixin {
  /// Constructor.
  const ThreadVisitHistoryState({this.status = ThreadVisitHistoryStatus.initial, this.history = const []});

  /// Current status.
  final ThreadVisitHistoryStatus status;

  /// All history.
  final List<ThreadVisitHistoryModel> history;
}
