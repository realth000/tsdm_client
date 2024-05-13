part of 'broadcast_message_detail_cubit.dart';

/// Status.
enum BroadcastMessageDetailStatus {
  /// Initial.
  initial,

  /// Loading data.
  loading,

  /// Succeed.
  success,

  /// Failed.
  failed,
}

/// State of broadcast message detail page.
@MappableClass()
final class BroadcastMessageDetailState
    with BroadcastMessageDetailStateMappable {
  /// Constructor.
  const BroadcastMessageDetailState({
    this.status = BroadcastMessageDetailStatus.initial,
    this.messageNode,
    this.dateTime,
  });

  /// Status
  final BroadcastMessageDetailStatus status;

  /// Detail message node.
  ///
  /// node:
  ///
  /// ```html
  /// <p class="pm_summary">
  ///   ...
  /// </p>
  /// ```
  final uh.Element? messageNode;

  /// Datetime of message.
  final DateTime? dateTime;
}
