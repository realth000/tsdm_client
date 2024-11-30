part of 'models.dart';

/// Models used for smms
///
/// ref: https://doc.sm.ms/#api-Image-Upload

/// Request model for smms.
@MappableClass()
final class SmmsRequest with SmmsRequestMappable {
  /// Constructor.
  const SmmsRequest({
    required this.token,
    required this.data,
  });

  /// Token to authorize.
  final String token;

  /// Image content, binary data.
  final Uint8List data;
}

/// Response model for smms.
///
/// Some fields are omitted.
@MappableClass()
final class SmmsResponse with SmmsResponseMappable {
  /// Constructor.
  const SmmsResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  /// Succeeded or not.
  final bool success;

  /// Text code.
  final String code;

  /// Text message.
  final String message;

  /// Data map.
  final SmmsResponseData? data;
}

/// Data field in [SmmsResponse].
@MappableClass()
final class SmmsResponseData with SmmsResponseDataMappable {
  /// Constructor.
  const SmmsResponseData({
    required this.width,
    required this.height,
    required this.url,
  });

  /// Image width.
  final int width;

  /// Image height.
  final int height;

  /// Direct url.
  final String url;
}
