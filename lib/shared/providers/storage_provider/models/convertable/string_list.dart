part of 'convertable.dart';

/// Converter between [List<String>] and [String].
class StringListConverter extends TypeConverter<List<String>, String> {
  /// Constructor.
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    // Dynamic is required in generic as it is.
    // ignore: avoid_dynamic
    final jsonMap = List.castFrom<dynamic, String>(jsonDecode(fromDb) as List<dynamic>);
    return jsonMap;
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
