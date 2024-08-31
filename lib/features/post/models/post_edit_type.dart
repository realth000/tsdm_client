part of 'models.dart';

/// Reason to enter the post edit page.
enum PostEditType {
  /// Write a new thread.
  newThread,

  /// Edit an existing post.
  editPost;

  /// Check whether the edit type is editing something.
  bool get isEditingPost => this == editPost;

  /// Check whether the edit type is writing new thread.
  bool get isDraftingNewThread => this == PostEditType.newThread;
}
