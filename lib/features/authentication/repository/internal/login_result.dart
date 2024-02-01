import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

/// Enum to represent whether a login attempt succeed.
enum LoginResult {
  /// Login success.
  success,

  /// Captcha is not correct.
  incorrectCaptcha,

  /// Maybe a login failed.
  ///
  /// When showing error messages or logging, record the original message.
  invalidUsernamePassword,

  /// Incorrect login question or answer
  incorrectQuestionOrAnswer,

  /// Too many login attempt and failure.
  attemptLimit,

  /// Other unrecognized error received from server.
  otherError,

  /// Unknown result.
  ///
  /// Treat as login failed.
  unknown;

  factory LoginResult.fromLoginMessageNode(uh.Element messageNode) {
    final message = messageNode
        .querySelector('div#messagetext > p')
        ?.nodes
        .firstOrNull
        ?.text;
    if (message == null) {
      const message = 'login result message text not found';
      debug('failed to check login result: $message');
      return LoginResult.unknown;
    }

    // Check message result node classes.
    // alert_right => login success.
    // alert_info  => login failed, maybe incorrect captcha.
    // alert_error => login failed, maybe invalid username or password.
    final messageClasses = messageNode.classes;

    if (messageClasses.contains('alert_right')) {
      if (message.contains('欢迎您回来')) {
        return LoginResult.success;
      }

      // Impossible unless server response page updated and changed these
      // messages.
      debug(
        'login result check passed but message check maybe outdated: $message',
      );
      return LoginResult.success;
    }

    if (messageClasses.contains('alert_info')) {
      if (message.contains('err_login_captcha_invalid')) {
        return LoginResult.incorrectCaptcha;
      }

      // Other unrecognized error.
      debug(
        'login result check not passed: '
        'alert_info class with unknown message: $message',
      );
      return LoginResult.otherError;
    }

    if (messageClasses.contains('alert_error')) {
      if (message.contains('登录失败')) {
        return LoginResult.invalidUsernamePassword;
      }

      if (message.contains('密码错误次数过多')) {
        return LoginResult.attemptLimit;
      }

      if (message.contains('请选择安全提问以及填写正确的答案')) {
        return LoginResult.incorrectQuestionOrAnswer;
      }

      // Other unrecognized error.
      debug(
        'login result check not passed: '
        'alert_error with unknown message: $message',
      );
      return LoginResult.otherError;
    }

    debug('login result check not passed: unknown result');
    return LoginResult.unknown;
  }
}
