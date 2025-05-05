part of 'convertable.dart';

/// Converter between [List<int>] and [String].
class IntListConverter extends TypeConverter<List<int>, String> {
  /// Constructor.
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) => jsonDecode(fromDb) as List<int>;

  @override
  String toSql(List<int> value) => jsonEncode(value);
}
