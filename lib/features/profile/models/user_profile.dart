part of 'models.dart';

/// User profile model.
@MappableClass()
class UserProfile with UserProfileMappable {
  /// Constructor.
  const UserProfile({
    required this.avatarUrl,
    required this.username,
    required this.uid,
    required this.emailVerified,
    required this.videoVerified,
    required this.customTitle,
    required this.signature,
    required this.friendsCount,
    required this.online,
    required this.birthdayYear,
    required this.birthdayMonth,
    required this.birthdayDay,
    required this.zodiac,
    required this.msn,
    required this.introduction,
    required this.nickname,
    required this.gender,
    required this.from,
    required this.qq,
    required this.profileMedals,
    required this.mangedForums,
    required this.checkinDaysCount,
    required this.checkinThisMonthCount,
    required this.checkinRecentTime,
    required this.checkinAllCoins,
    required this.checkinLastTimeCoin,
    required this.checkinLevel,
    required this.checkinNextLevel,
    required this.checkinNextLevelDays,
    required this.checkinTodayStatus,
    required this.moderatorGroup,
    required this.userGroup,
    required this.onlineTime,
    required this.registerTime,
    required this.lastVisitTime,
    required this.lastActiveTime,
    required this.registerIP,
    required this.lastVisitIP,
    required this.lastPostTime,
    required this.timezone,
    required this.credits,
    required this.famous,
    required this.coins,
    required this.publicity,
    required this.natural,
    required this.scheming,
    required this.spirit,
    required this.specialAttr,
    required this.specialAttrName,
  });

  /// Url of user avatar.
  final String? avatarUrl;

  /// Username.
  final String? username;

  /// User id.
  final String? uid;

  ///////////  Basic status ///////////

  /// Group of basic info.
  ///
  /// Each group contains a string of title and a string of subtitle.

  /// User email is verified or not
  final bool? emailVerified;

  /// User verified through video.
  final bool? videoVerified;

  /// User custom title.
  final String? customTitle;

  /// User signature.
  ///
  /// Html code.
  final String? signature;

  /// Friends count.
  ///
  /// Should be a widget redirect to user friends page.
  final String? friendsCount;

  /// User currently online or not.
  final bool online;

  ///////////  Some other basic status ///////////

  /// Year of birthday.
  final String? birthdayYear;

  /// Month of birthday.
  final String? birthdayMonth;

  /// Day of birthday.
  final String? birthdayDay;

  /// User zodiac.
  final String? zodiac;

  /// MSN number.
  final String? msn;

  /// Self introduction.
  final String? introduction;

  /// User nickname.
  final String? nickname;

  /// User gender.
  final String? gender;

  /// From location.
  final String? from;

  /// QQ number.
  final String? qq;

  /// Medal info formatted in profile page.
  final List<ProfileMedal>? profileMedals;

  /// All managed forums.
  ///
  /// Have moderator permission.
  final List<ManagedForum>? mangedForums;

  ///////////  Checkin status ///////////

  /// Total checkin days count.
  ///
  /// Always not zero.
  final int? checkinDaysCount;

  /// Checkin days in current month.
  final String? checkinThisMonthCount;

  /// Last checkin time.
  final String? checkinRecentTime;

  /// All coins got by checking.
  final String? checkinAllCoins;

  /// Coins got in last checkin.
  final String? checkinLastTimeCoin;

  /// Level of checkin.
  final String? checkinLevel;

  /// Next level of checkin.
  final String? checkinNextLevel;

  /// Days till next level of checkin.
  ///
  /// Always not zero.
  final int? checkinNextLevelDays;

  /// Today checked or not.
  final String? checkinTodayStatus;

  ///////////  User group status ///////////

  /// Info about group of moderator.
  ///
  /// Html format.
  ///
  /// May be null if user is not any kind of moderator.
  final String? moderatorGroup;

  /// Info about normal user group.
  ///
  /// Html format.
  ///
  /// Generally not null.
  final String? userGroup;

  ///////////  Activity status ///////////

  /// Group of user activity information.
  ///
  /// Each group contains a string of title and a string of subtitle.

  /// Total online time.
  final String? onlineTime;

  /// Datetime of account registration.
  final DateTime? registerTime;

  /// Datetime of last visit.
  final DateTime? lastVisitTime;

  /// Account last active time.
  final DateTime? lastActiveTime;

  /// IP address when account registered.
  ///
  /// Personal privacy info.
  final String? registerIP;

  /// IP address when last visit.
  ///
  /// Personal privacy info.
  final String? lastVisitIP;

  /// Datetime of last post content.
  final DateTime? lastPostTime;

  /// User timezone.
  final String? timezone;

  ///////////  Statistics status ///////////

  /// 积分
  final String? credits;

  /// 威望
  final String? famous;

  /// 天使币
  final String? coins;

  /// 宣传
  final String? publicity;

  /// 天然
  final String? natural;

  /// 腹黑
  final String? scheming;

  /// 精灵
  final String? spirit;

  /// Special attr changes over time.
  ///
  /// 龙之印章/西瓜/爱心/金蛋
  final String? specialAttr;

  /// Special attr name.
  final String? specialAttrName;
}
