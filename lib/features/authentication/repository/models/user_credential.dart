part of 'models.dart';

/// User name field type, pair with password.
enum LoginField {
  /// Username
  username,

  /// Email address.
  email,

  /// Uid
  uid;

  @override
  String toString() {
    return switch (this) {
      LoginField.username => 'username',
      LoginField.email => 'email',
      LoginField.uid => 'uid',
    };
  }
}

/// Additional security question.
@MappableClass()
class SecurityQuestion with SecurityQuestionMappable {
  /// Constructor.
  const SecurityQuestion({required this.questionId, required this.answer});

  /// The question id of security question chose by user.
  final String questionId;

  /// The answer text that user texted.
  final String answer;
}

/// Login credential.
@MappableClass(generateMethods: GenerateMethods.stringify | GenerateMethods.copy | GenerateMethods.equals)
class UserCredential with UserCredentialMappable {
  /// Constructor.
  const UserCredential({
    required this.loginField,
    required this.loginFieldValue,
    required this.password,
    // required this.formHash,
    required this.tsdmVerify,
    // this.referer = homePage,
    // this.cookieTime = defaultCookieTime,
    this.securityQuestion,
    // this.loginSubmit = true,
  });

  /// Which name field stands for.
  final LoginField loginField;

  /// Name field value.
  final String loginFieldValue;

  /// Password.
  final String password;

  // /// Form hash.
  // final String formHash;

  /// Verify code.
  final String tsdmVerify;

  // /// Referer in request.
  // ///
  // /// Default is [homePage].
  // final String referer;

  // /// Cookie persistent time.
  // ///
  // /// Default is [defaultCookieTime].
  // final int cookieTime;

  // /// Login submit in web request.
  // ///
  // /// Default is true.
  // final bool loginSubmit;

  /// Security question in web request.
  ///
  /// Can be null.
  final SecurityQuestion? securityQuestion;

  /// Method to convert to json.
  Map<String, dynamic> toJson() {
    final m = {
      'fastloginfield': loginField.toString(),
      'username': loginFieldValue,
      'password': password,
      // 'formhash': formHash,
      'tsdm_verify': tsdmVerify,
      // 'referer': referer,
      // 'cookietime': cookieTime,
      // 'loginsubmit': loginSubmit,
    };

    if (securityQuestion != null) {
      m['questionid'] = securityQuestion!.questionId;
      m['answer'] = securityQuestion!.answer;
    }

    return m;
  }
}
