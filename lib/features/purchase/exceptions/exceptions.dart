/// Basic exception class that may happen in purchasing.
sealed class PurchaseInfoFailedException implements Exception {}

/// Failed to parse purchase info because the parameter in
/// confirm info is incorrect.
final class PurchaseInfoInvalidParameterCountException
    extends PurchaseInfoFailedException {}

/// Confirm info is incomplete.
final class PurchaseInfoIncompleteException
    extends PurchaseInfoFailedException {}

/// Some info that need to display in the confirm process is invalid.
///
/// Maybe invalid username or uid.
final class PurchaseInfoInvalidNoticeException
    extends PurchaseInfoFailedException {}

/// Failed to do the purchase action.
final class PurchaseActionFailedException implements Exception {}
