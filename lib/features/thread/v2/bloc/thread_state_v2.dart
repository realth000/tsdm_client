part of 'thread_bloc_v2.dart';

/// V2 Status
enum ThreadStatusV2 {
  /// Initial.
  initial,

  /// Loading date for the first time.
  loading,

  /// Load succeed.
  success,

  /// Load failed.
  failure,
}

/// V2 state of thread bloc.
///
/// We can not get rid of the separated status and state format because some
/// thread data info still need to be kept when loading data or failed to do
/// some actions otherwise it costs too much that user lost all he .
@MappableClass()
final class ThreadStateV2 with ThreadStateV2Mappable {
  /// Constructor.
  ThreadStateV2({
    required this.threadId,
    this.author,
    this.authorId,
    this.pageRange,
    this.forumId,
    this.status = ThreadStatusV2.initial,
    this.title,
    this.postList = const [],
    this.totalPost = 1,
    this.postPerPage = 10,
    this.moderator = 0,
    this.scoreInfo = const {},
    this.price = '0',
    this.paid = 1,
  }) : entirePageRange =
            PageRange(start: 1, end: (totalPost / postPerPage).ceil());

  /// The id of current thread.
  final String threadId;

  /// Current status.
  final ThreadStatusV2 status;

  /// Thread title or call it subject.
  final String? title;

  /// All post.
  final List<PostV2> postList;

  /// Total count of post.
  final int totalPost;

  /// Maximum posts count in each page.
  final int postPerPage;

  /// The fid of subreddit the thread currently lives in.
  final String? forumId;

  /// Author username.
  final String? author;

  /// Thread author id.
  final int? authorId;

  /// Current user is the moderator of current thread.
  ///
  /// * Current user is the user visiting thread, not the thread author.
  final int moderator;

  /// Info about score attribute names and ids.
  ///
  /// All thread shall be the same but use and update every time for safety.
  final Map<String, String> scoreInfo;

  /// Thread price, if any.
  final String price;

  /// Current user has paid for the thread or does not need to pay.
  ///
  /// * Current user is the user visiting thread, not the thread author.
  ///
  /// 1 for paid or not need to pay.
  final int paid;

  /// Page range of currently loaded page.
  final PageRange? pageRange;

  /// The page range of all pages.
  ///
  /// From 1 to n where n is ceil([totalPost] / [postPerPage]).
  final PageRange entirePageRange;
}
