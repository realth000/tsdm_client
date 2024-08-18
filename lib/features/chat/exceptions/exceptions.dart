import 'package:dart_mappable/dart_mappable.dart';

part 'exceptions.mapper.dart';

/// Chat html document not found.
@MappableClass()
final class ChatDataDocumentNotFoundException
    with ChatDataDocumentNotFoundExceptionMappable
    implements Exception {}
