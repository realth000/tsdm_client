import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';

/// Settings for Dio.
@freezed
class Settings with _$Settings {
  /// Freezed constructor.
  const factory Settings({
    required String dioAccept,
    required String dioAcceptEncoding,
    required String dioAcceptLanguage,
    required String dioUserAgent,
  }) = _Settings;
}

/// All settings names (as keys) and settings value types (as values).
const settingsMap = <String, Type>{
  'dioAccept': String,
  'dioAcceptEncoding': String,
  'dioAcceptLanguage': String,
  'dioUserAgent': String,
};
