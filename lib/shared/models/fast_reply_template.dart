part of 'models.dart';

/// The model of fast reply.
@MappableClass()
final class FastReplyTemplateModel with FastReplyTemplateModelMappable {
  /// Constructor.
  const FastReplyTemplateModel({required this.name, required this.data});

  /// Template name.
  final String name;

  /// Data contents.
  final String data;
}
