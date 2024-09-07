part of 'models.dart';

/// Reason to enter the post edit page.
enum PostEditType {
  /// Write a new thread.
  newThread,

  /// Edit an existing post.
  editPost,

  /// Editing a thread that still in draft state (not published yet).
  ///
  /// This type is similar to [newThread] and [editPost], only on editing the
  /// first floor post, fetch info like [editPost] but have save-as-draft
  /// action.
  editDraft;

  /// Check whether the edit type is editing something.
  bool get isEditingPost => this == editPost;

  /// Check whether the edit type is writing new thread.
  bool get isEditingDraft =>
      this == PostEditType.newThread || this == PostEditType.editDraft;
}
