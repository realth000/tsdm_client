import 'package:flutter/foundation.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';

/// Logger mixin.
///
/// Provides logger functions.
mixin LoggerMixin {
  /// 近在Debug下打印
  void onlyDebug(
    dynamic message, [
    Object? exception,
    StackTrace? stackTrace,
  ]) {
    if (!kDebugMode) {
      return;
    }
    debug(message, exception, stackTrace);
  }

  /// Debug级
  void debug(
    dynamic message, [
    Object? exception,
    StackTrace? stackTrace,
  ]) {
    talker.debug('$runtimeType: $message', exception, stackTrace);
  }

  /// Info级
  void info(
    dynamic message, [
    Object? exception,
    StackTrace? stackTrace,
  ]) {
    talker.info('$runtimeType: $message', exception, stackTrace);
  }

  /// Warning级
  void warning(
    dynamic message, [
    Object? exception,
    StackTrace? stackTrace,
  ]) {
    talker.warning('$runtimeType: $message', exception, stackTrace);
  }

  /// Error级
  void error(
    dynamic message, [
    Object? exception,
    StackTrace? stackTrace,
  ]) {
    talker.error('$runtimeType: $message', exception, stackTrace);
  }

  /// Exception
  void handle(AppException exception) {
    talker
      ..error('$runtimeType: handle error:')
      ..handle(exception, exception.stackTrace, exception.message);
  }

  /// Handle [exception] then run [callback].
  void handleThen(AppException exception, VoidCallback callback) {
    handle(exception);
    callback();
  }
}
