part of 'convertable.dart';

/// Converter between [List<int>] and [String].
class IntListConverter extends TypeConverter<List<int>, String> {
  /// Constructor.
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) {
    // Dynamic is required in generic as it is.
    // ignore: avoid_dynamic
    final jsonMap = List.castFrom<dynamic, int>(jsonDecode(fromDb) as List<dynamic>);
    return jsonMap;
  }

  @override
  String toSql(List<int> value) => jsonEncode(value);
}
