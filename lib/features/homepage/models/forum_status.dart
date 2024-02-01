import 'package:equatable/equatable.dart';

/// Some forum status information showed in homepage.
///
/// Including threads/replies in today and yesterday, and member count.
final class ForumStatus extends Equatable {
  /// Constructor.
  const ForumStatus({
    required this.todayCount,
    required this.yesterdayCount,
    required this.threadCount,
  });

  /// Construct an empty forum status.
  const ForumStatus.empty()
      : todayCount = '0',
        yesterdayCount = '0',
        threadCount = '0';

  /// "今日"
  final String todayCount;

  /// "昨日"
  final String yesterdayCount;

  /// "帖子"
  final String threadCount;

  @override
  List<Object?> get props => [todayCount, yesterdayCount, threadCount];
}
