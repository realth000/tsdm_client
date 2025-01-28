part of 'models.dart';

/// Thread model v2.
///
/// Each instance represents a page of thread.
@MappableClass()
final class ThreadV2 with ThreadV2Mappable {
  /// Constructor.
  const ThreadV2({
    required this.postList,
    required this.totalPost,
    required this.postPerPage,
    required this.title,
    required this.forumId,
    required this.author,
    required this.authorId,
    required this.moderator,
    required this.scoreInfo,
    required this.price,
    required this.paid,
  });

  /// All post in current page of thread.
  @MappableField(key: 'postlist')
  final List<PostV2> postList;

  /// Count of post in thread, excluding the first floor.
  @MappableField(key: 'totalpost')
  final String totalPost;

  /// Maximum post count in each page.
  @MappableField(key: 'tpp')
  final String postPerPage;

  /// Title of the thread.
  @MappableField(key: 'subject')
  final String title;

  /// Forum id of subreddit the thread currently lives in.
  @MappableField(key: 'fid')
  final String forumId;

  /// Username of the author.
  @MappableField(key: 'thread_author')
  final String author;

  /// Uid of the author.
  @MappableField(key: 'thread_authorid')
  final String authorId;

  /// If the current user visiting thread is the moderator of the subreddit that
  /// the thread lives in.
  ///
  /// 1 if true.
  @MappableField(key: 'ismoderator')
  final int moderator;

  /// User attr info map.
  @MappableField(key: 'extcreditsname')
  final Map<String, String> scoreInfo;

  /// Price of the thread.
  @MappableField(key: 'thread_price')
  final String price;

  /// Already paid or do not need to pay.
  @MappableField(key: 'thread_paid')
  final int paid;
}
