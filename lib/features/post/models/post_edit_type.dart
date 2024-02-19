/// Reason to enter the post edit page.
enum PostEditType {
  /// Write a new post.
  newPost,

  /// Write a new thread.
  newThread,

  /// Edit an existing post.
  editPost;

  /// Check whether the edit type is editing something.
  bool get isEditType => this == editPost;
}
