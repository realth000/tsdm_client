import 'package:dart_mappable/dart_mappable.dart';

part '../../../generated/features/chat/exceptions/exceptions.mapper.dart';

/// Chat html document not found.
@MappableClass()
final class ChatDataDocumentNotFoundException
    with ChatDataDocumentNotFoundExceptionMappable
    implements Exception {}
