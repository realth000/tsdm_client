/// Defines usage types of `ReplyBar`.
///
/// In different pages use different states and logic.
enum ReplyTypes {
  /// Reply in thread pages.
  thread,

  /// Reply a to notification, usually in a NoticeDetailPage.
  ///
  /// With this
  notice,

  /// Reply in chat history pages.
  chatHistory,

  /// Reply in chat page.
  chat,
}
