part of 'convertable.dart';

/// Converter between [List<String>] and [String].
class StringListConverter extends TypeConverter<List<String>, String> {
  /// Constructor.
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) => jsonDecode(fromDb) as List<String>;

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
