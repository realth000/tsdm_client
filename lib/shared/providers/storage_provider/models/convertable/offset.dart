part of 'convertable.dart';

/// Converter between [Offset] and [String].
class OffsetConverter extends TypeConverter<Offset, String> {
  /// Internal constructor.
  const OffsetConverter();

  static const _keyDx = 'dx';
  static const _keyDy = 'dy';

  @override
  Offset fromSql(String fromDb) {
    // Dynamic is required in generic as it is.
    // ignore: avoid_dynamic
    final jsonMap = Map.castFrom<String, dynamic, String, double>(jsonDecode(fromDb) as Map<String, dynamic>);
    return Offset(jsonMap[_keyDx]!, jsonMap[_keyDy]!);
  }

  @override
  String toSql(Offset value) => jsonEncode(<String, double>{_keyDx: value.dx, _keyDy: value.dy});
}
