part of 'convertable.dart';

/// Converter between [Offset] and [String].
class OffsetConverter extends TypeConverter<Offset, String> {
  /// Internal constructor.
  const OffsetConverter();

  static const _keyDx = 'dx';
  static const _keyDy = 'dy';

  @override
  Offset fromSql(String fromDb) {
    final jsonMap = jsonDecode(fromDb) as Map<String, double>;
    return Offset(jsonMap[_keyDx]!, jsonMap[_keyDy]!);
  }

  @override
  String toSql(Offset value) => jsonEncode(<String, double>{
        _keyDx: value.dx,
        _keyDy: value.dy,
      });
}
