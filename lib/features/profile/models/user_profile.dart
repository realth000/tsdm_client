part of 'models.dart';

/// User profile model.
@MappableClass()
class UserProfile with UserProfileMappable {
  /// Constructor.
  const UserProfile({
    required this.avatarUrl,
    required this.username,
    required this.uid,
    required this.basicInfoList,
    required this.checkinDaysCount,
    required this.checkinThisMonthCount,
    required this.checkinRecentTime,
    required this.checkinAllCoins,
    required this.checkinLastTimeCoin,
    required this.checkinLevel,
    required this.checkinNextLevel,
    required this.checkinNextLevelDays,
    required this.checkinTodayStatus,
    required this.activityInfoList,
  });

  /// Url of user avatar.
  final String? avatarUrl;

  /// Username.
  final String? username;

  /// User id.
  final String? uid;

  /// Group of basic info.
  ///
  /// Each group contains a string of title and a string of subtitle.
  final List<(String title, String subtitle)> basicInfoList;

  /// Total checkin days count.
  final String? checkinDaysCount;

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

  /// Days till next level of chekcin.
  final String? checkinNextLevelDays;

  /// Today checked or not.
  final String? checkinTodayStatus;

  /// Group of user activity information.
  ///
  /// Each group contains a string of title and a string of subtitle.
  final List<(String title, String subtitle)> activityInfoList;
}
