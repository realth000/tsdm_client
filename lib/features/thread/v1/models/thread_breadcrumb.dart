part of 'models.dart';

/// The definition of all kinds of thread breadcrumb.
///
/// A thread breadcrumb is a part of the navigation position of current thread.
///
/// ```console
/// Home > subreddit1 > subreddit1.1 > subreddit1.1.1 > current_thread
/// ```
///
/// Every piece of thread is a breadcrumb instance.
@MappableClass()
final class ThreadBreadcrumb with ThreadBreadcrumbMappable {
  /// Constructor.
  const ThreadBreadcrumb({required this.description, required this.link});

  /// The description of current breadcrumb.
  final String description;

  /// Url link that can navigate to.
  final String link;
}
