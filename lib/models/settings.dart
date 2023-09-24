import 'package:freezed_annotation/freezed_annotation.dart';

part '../generated/models/settings.freezed.dart';

/// Settings for Dio.
@freezed
class Settings with _$Settings {
  /// Freezed constructor.
  const factory Settings({
    required String dioAccept,
    required String dioAcceptEncoding,
    required String dioAcceptLanguage,
    required String dioUserAgent,
    required double windowWidth,
    required double windowHeight,
    required double windowPositionDx,
    required double windowPositionDy,
    required bool windowInCenter,
    required int loginUserUid,
  }) = _Settings;
}

/// All settings names (as keys) and settings value types (as values).
const settingsMap = <String, Type>{
  'dioAccept': String,
  'dioAcceptEncoding': String,
  'dioAcceptLanguage': String,
  'dioUserAgent': String,
  'windowWidth': double,
  'windowHeight': double,
  'windowPositionDx': double,
  'windowPositionDy': double,
  'windowInCenter': bool,
  'loginUserUid': int,
};
