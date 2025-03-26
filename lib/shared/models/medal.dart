import 'package:dart_mappable/dart_mappable.dart';

part 'medal.mapper.dart';

/// User medal.
///
/// This medal is the parsed one type can be directly rendered on screen.
@MappableClass()
final class Medal with MedalMappable {
  /// Constructor.
  const Medal({required this.name, required this.image, required this.alter, required this.description});

  /// Medal name.
  final String name;

  /// Image url.
  final String image;

  /// Alter text.
  final String alter;

  /// Medal description.
  final String description;
}
