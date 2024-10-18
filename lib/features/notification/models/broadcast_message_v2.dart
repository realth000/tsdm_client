part of 'models.dart';

/// Model for broadcast message in API.
@MappableClass()
final class BroadcastMessageV2 with BroadcastMessageV2Mappable {
  /// Constructor.
  const BroadcastMessageV2({
    required this.timestamp,
    required this.data,
    required this.pmid,
  });

  /// Timestamp in seconds.
  final int timestamp;

  /// Content preview in plain text.
  @MappableField(key: 'preview')
  final String data;

  /// Message id.
  final int pmid;
}
