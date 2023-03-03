/// Thread type
///
/// 宣传、心情、其他……
class ThreadType {
  /// Constructor.
  ThreadType(this.name, this.url);

  /// Type name: 宣传。
  String name;

  /// Type url.
  String url;
}

/// Author of a thread.
///
/// Contains name and user page url.
class ThreadAuthor {
  /// Constructor.
  ThreadAuthor(this.name, this.url);

  ///  Name of the author.
  String name;

  /// User page url.
  String url;
}

/// Model of normal thread;
class NormalThread {
  /// Constructor.
  NormalThread({
    required this.title,
    required this.author,
    required this.publishTime,
    required this.lastReplyAuthor,
    required this.lastReplyTime,
    required this.iconUrl,
    required this.replyCount,
    required this.viewCount,
    this.threadType,
    this.price = 0,
  });

  /// Icon of this thread.
  String? iconUrl;

  /// ThreadType.
  ThreadType? threadType;

  /// Title of the thread.
  String title;

  /// Price of the thread.
  ///
  /// May be 0.
  int price;

  /// Author of the thread.
  ThreadAuthor author;

  /// Publish time of the thread.
  DateTime publishTime;

  /// Count of reply in the thread.
  ///
  /// >= 0;
  int replyCount;

  /// Count of user views times of the thread.
  ///
  /// >= 0;
  int viewCount;

  /// Last reply of this thread.
  ///
  /// At least is the same with [author], never be null.
  late ThreadAuthor lastReplyAuthor;

  /// Last reply time of the thread.
  late DateTime lastReplyTime;
}
