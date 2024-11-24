part of 'models.dart';

/// Model for v2 version of user profile.
@MappableClass()
final class UserProfileV2 with UserProfileV2Mappable {
  /// Constructor.
  const UserProfileV2({
    required this.uid,
    required this.username,
    required this.nickname,
    required this.groupId,
    required this.adminId,
    required this.points,
    required this.miku,
    required this.threadCount,
    required this.postCount,
    required this.perm,
    required this.registrationDate,
    required this.coupleUid,
    required this.coupleUsername,
    required this.title,
    required this.avatarUrl,
    required this.credits1,
    required this.credits2,
    required this.credits3,
    required this.credits4,
    required this.credits5,
    required this.credits6,
    required this.credits7,
  });

  /// User id.
  final int uid;

  /// Username.
  final String username;

  /// Nickname
  ///
  /// 昵称
  final String nickname;

  /// User group id
  @MappableField(key: 'gid')
  final int groupId;

  /// User administrator id.
  @MappableField(key: 'aid')
  final int adminId;

  /// Points
  @MappableField(key: 'credits')
  final int points;

  /// Some state not used.
  final int miku;

  /// Thread posted count.
  ///
  /// 主题
  @MappableField(key: 'threads')
  final int threadCount;

  /// Posts posted count.
  ///
  /// 帖子
  @MappableField(key: 'posts')
  final int postCount;

  /// Perm to access thread.
  ///
  /// 阅读权限
  @MappableField(key: 'readaccess')
  final int perm;

  /// Time of registration.
  ///
  /// Formatted in yyyy-MM-dd HH:mm
  @MappableField(key: 'regdate')
  final String registrationDate;

  /// Couple uid.
  @MappableField(key: 'cpuid')
  final int coupleUid;

  /// Couple username.
  @MappableField(key: 'cpusername')
  final String coupleUsername;

  /// Custom title.
  ///
  /// 自定义头衔
  @MappableField(key: 'customstatus')
  final String title;

  /// Url of user avatar.
  @MappableField(key: 'avatar')
  final String avatarUrl;

  /// User credits.
  ///
  /// Formatted as "key:value"
  @MappableField(key: 'extcredits1')
  final String credits1;

  /// User credits.
  ///
  /// Formatted as "key:value"
  @MappableField(key: 'extcredits2')
  final String credits2;

  /// User credits.
  ///
  /// Formatted as "key:value"
  @MappableField(key: 'extcredits3')
  final String credits3;

  /// User credits.
  ///
  /// Formatted as "key:value"
  @MappableField(key: 'extcredits4')
  final String credits4;

  /// User credits.
  ///
  /// Formatted as "key:value"
  @MappableField(key: 'extcredits5')
  final String credits5;

  /// User credits.
  ///
  /// Formatted as "key:value"
  @MappableField(key: 'extcredits6')
  final String credits6;

  /// User credits.
  ///
  /// Formatted as "key:value"
  @MappableField(key: 'extcredits7')
  final String credits7;
}
