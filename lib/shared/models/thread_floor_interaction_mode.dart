/// Interaction on thread floors.
///
/// Each mode defines a way to interact on post floors in thread page, especially how to reply.
enum ThreadFloorInteractionMode {
  /// Adaptively open context menu of the post floor where provides reply action.
  ///
  /// * On mobile platforms, use long press.
  /// * On desktop platforms, use right click.
  adaptiveTapMenu,

  /// Tap the floor will set the reply target to current floor.
  ///
  /// Old behavior.
  tapToReply,
}
