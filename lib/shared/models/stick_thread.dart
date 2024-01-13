import 'package:tsdm_client/shared/models/normal_thread.dart';
import 'package:universal_html/html.dart' as uh;

/// Pinned thread.
class StickThread extends NormalThread {
  StickThread({
    required super.title,
    required super.url,
    required super.threadID,
    required super.author,
    required super.publishDate,
    required super.latestReplyAuthor,
    required super.latestReplyTime,
    required super.iconUrl,
    required super.threadType,
    required super.replyCount,
    required super.viewCount,
    required super.price,
    required super.css,
    required super.stateSet,
  });

  /// Build a [StickThread] from [threadElement] <tbody id="stickthread_xxx">.
  ///
  /// As same as building a normal thread.
  static StickThread? fromTBody(uh.Element threadElement) {
    final t = NormalThread.fromTBody(threadElement);
    if (t == null) {
      return null;
    }
    return StickThread(
      title: t.title,
      url: t.url,
      threadID: t.threadID,
      author: t.author,
      publishDate: t.publishDate,
      latestReplyAuthor: t.latestReplyAuthor,
      latestReplyTime: t.latestReplyTime,
      iconUrl: t.iconUrl,
      threadType: t.threadType,
      replyCount: t.replyCount,
      viewCount: t.viewCount,
      price: t.price,
      css: t.css,
      stateSet: t.stateSet,
    );
  }
}
