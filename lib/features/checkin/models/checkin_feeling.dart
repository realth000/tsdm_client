part of 'models.dart';

/// All checkin feelings.
enum CheckinFeeling {
  /// 开心
  happy,

  /// 伤心
  sad,

  /// 郁闷
  depressed,

  /// 无聊
  boring,

  /// 生气
  angry,

  /// 无语
  speechless,

  /// 奋斗
  struggle,

  /// 慵懒
  lazy,

  /// 倒霉
  unlucky;

  factory CheckinFeeling.from(String feeling) {
    return switch (feeling) {
      'kx' => CheckinFeeling.happy,
      'ng' => CheckinFeeling.sad,
      'ym' => CheckinFeeling.depressed,
      'wl' => CheckinFeeling.boring,
      'nu' => CheckinFeeling.angry,
      'ch' => CheckinFeeling.speechless,
      'fd' => CheckinFeeling.struggle,
      'yl' => CheckinFeeling.lazy,
      'shuai' => CheckinFeeling.unlucky,
      String() => CheckinFeeling.happy,
    };
  }

  @override
  String toString() {
    return switch (this) {
      CheckinFeeling.happy => 'kx',
      CheckinFeeling.sad => 'ng',
      CheckinFeeling.depressed => 'ym',
      CheckinFeeling.boring => 'wl',
      CheckinFeeling.angry => 'nu',
      CheckinFeeling.speechless => 'ch',
      CheckinFeeling.struggle => 'fd',
      CheckinFeeling.lazy => 'yl',
      CheckinFeeling.unlucky => 'shuai',
    };
  }

  /// Translate [CheckinFeeling] into human readable string.
  String translate(BuildContext context) {
    return switch (this) {
      CheckinFeeling.happy => context.t.feelingList.happy,
      CheckinFeeling.sad => context.t.feelingList.sad,
      CheckinFeeling.depressed => context.t.feelingList.depressed,
      CheckinFeeling.boring => context.t.feelingList.boring,
      CheckinFeeling.angry => context.t.feelingList.angry,
      CheckinFeeling.speechless => context.t.feelingList.speechless,
      CheckinFeeling.struggle => context.t.feelingList.struggling,
      CheckinFeeling.lazy => context.t.feelingList.lazy,
      CheckinFeeling.unlucky => context.t.feelingList.unlucky,
    };
  }
}
