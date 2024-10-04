part of 'convertable.dart';

/// Converter between [Size] and [String].
class SizeConverter extends TypeConverter<Size, String> {
  /// Constructor.
  const SizeConverter();

  static const _keyWidth = 'width';
  static const _keyHeight = 'height';

  @override
  Size fromSql(String fromDb) {
    final jsonMap = jsonDecode(fromDb) as Map<String, double>;
    return Size(jsonMap[_keyWidth]!, jsonMap[_keyHeight]!);
  }

  @override
  String toSql(Size value) => jsonEncode(<String, double>{
        _keyWidth: value.width,
        _keyHeight: value.height,
      });
}
