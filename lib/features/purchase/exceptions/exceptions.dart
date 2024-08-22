import 'package:dart_mappable/dart_mappable.dart';

part 'exceptions.mapper.dart';

/// Basic exception class that may happen in purchasing.
@MappableClass()
sealed class PurchaseInfoFailedException
    with PurchaseInfoFailedExceptionMappable
    implements Exception {}
