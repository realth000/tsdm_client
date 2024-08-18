import 'package:dart_mappable/dart_mappable.dart';

part 'exceptions.mapper.dart';

/// Basic exception class that may happen in purchasing.
@MappableClass()
sealed class PurchaseInfoFailedException
    with PurchaseInfoFailedExceptionMappable
    implements Exception {}

/// Failed to parse purchase info because the parameter in
/// confirm info is incorrect.
@MappableClass()
final class PurchaseInfoInvalidParameterCountException
    extends PurchaseInfoFailedException
    with PurchaseInfoInvalidParameterCountExceptionMappable {}

/// Confirm info is incomplete.
@MappableClass()
final class PurchaseInfoIncompleteException extends PurchaseInfoFailedException
    with PurchaseInfoIncompleteExceptionMappable {}

/// Some info that need to display in the confirm process is invalid.
///
/// Maybe invalid username or uid.
@MappableClass()
final class PurchaseInfoInvalidNoticeException
    extends PurchaseInfoFailedException
    with PurchaseInfoInvalidNoticeExceptionMappable {}

/// Failed to do the purchase action.
@MappableClass()
final class PurchaseActionFailedException
    with PurchaseActionFailedExceptionMappable
    implements Exception {}
