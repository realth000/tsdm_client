import 'package:dart_mappable/dart_mappable.dart';

part 'birthday_info.mapper.dart';

/// Extension for user profile field visibility.
extension UserProfileFieldVisibilityExt on String {
  /// Get the visibility key of current user profile field.
  String visibility() => 'privacy[$this]';
}

/// All keys in profile.
///
/// These keys are used by server side to locate the item in user profile.
abstract class UserProfileKeys {
  /// gender => gender.
  static const gender = 'gender';

  /// birthday year => birthyear.
  static const birthYear = 'birthyear';

  /// birthday month => birthmonth.
  static const birthMonth = 'birthmonth';

  /// birthday => birthday.
  ///
  /// Specify the day and 'birthday' field.
  static const birthday = 'birthday';

  /// qq => qq.
  static const qq = 'qq';

  /// msn => msn.
  static const msn = 'msn';

  /// homepage => site.
  static const homepage = 'site';

  /// bio => bio.
  static const bio = 'bio';

  /// hobby => interest.
  static const hobby = 'interest';

  /// location => field2.
  static const location = 'field2';

  /// nickname => field1.
  static const nickname = 'field1';

  /// words to say => field6.
  static const wordsToSay = 'field6';

  /// skill => field5.
  static const skill = 'field5';

  /// favorite bangumi => field4.
  static const favoriteBangumi = 'field4';

  /// web page style => styleid.
  static const pageStyle = 'styleid';

  /// custom title => customstatus.
  static const customTitle = 'customstatus';

  /// signature => sightml.
  static const signature = 'sightml';

  /// timezone => timeoffset.
  static const timezone = 'timeoffset';
}

/// Data class to pass date info for editing.
@MappableClass()
final class BirthdayInfo with BirthdayInfoMappable {
  /// Constructor.
  const BirthdayInfo({
    required this.year,
    required this.month,
    required this.day,
  });

  /// Year.
  final int? year;

  /// Month.
  ///
  /// 1-12.
  final int? month;

  /// Day.
  final int? day;
}
