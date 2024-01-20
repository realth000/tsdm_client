sealed class PurchaseInfoFailedException implements Exception {}

final class PurchaseInfoInvalidParameterCountException
    extends PurchaseInfoFailedException {}

final class PurchaseInfoIncompleteException
    extends PurchaseInfoFailedException {}

final class PurchaseInfoInvalidNoticeException
    extends PurchaseInfoFailedException {}

final class PurchaseActionFailedException implements Exception {}
