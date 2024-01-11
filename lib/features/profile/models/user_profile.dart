import 'package:equatable/equatable.dart';

/// User profile model.
class UserProfile extends Equatable {
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

  final String? avatarUrl;
  final String? username;
  final String? uid;
  final List<(String title, String subtitle)> basicInfoList;
  final String? checkinDaysCount;
  final String? checkinThisMonthCount;
  final String? checkinRecentTime;
  final String? checkinAllCoins;
  final String? checkinLastTimeCoin;
  final String? checkinLevel;
  final String? checkinNextLevel;
  final String? checkinNextLevelDays;
  final String? checkinTodayStatus;
  final List<(String title, String subtitle)> activityInfoList;

  @override
  List<Object?> get props => [
        avatarUrl,
        username,
        basicInfoList,
        checkinDaysCount,
        checkinThisMonthCount,
        checkinRecentTime,
        checkinAllCoins,
        checkinLastTimeCoin,
        checkinLevel,
        checkinNextLevel,
        checkinNextLevelDays,
        activityInfoList,
      ];
}
