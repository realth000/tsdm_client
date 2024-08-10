import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/authentication/bloc/authentication_bloc.dart';
import 'package:tsdm_client/features/authentication/repository/models/models.dart';
import 'package:tsdm_client/features/authentication/widgets/captcha_image.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';

// TODO: Fetch login questions dynamically from web server.
final _loginQuestions = [
  '无安全问题',
  '母亲的名字',
  '爷爷的名字',
  '父亲出生的城市',
  '您其中一位老师的名字',
  '您个人计算机的型号',
  '您最喜欢的餐馆名称',
  '驾驶执照的最后四位数字',
];

/// Form for user to fill login info.
class LoginForm extends StatefulWidget {
  /// Constructor.
  const LoginForm({
    this.redirectPath,
    this.redirectPathParameters,
    this.redirectExtra,
    super.key,
  });

  /// The url path to redirect back once login succeed.
  final String? redirectPath;

  /// The path parameters of url to redirect back.
  final Map<String, String>? redirectPathParameters;

  /// The extra object of url to redirect back.
  final Object? redirectExtra;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with LoggerMixin {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  late final TextEditingController answerController;
  late final TextEditingController verifyCodeController;

  bool _showPassword = false;

  String _question = _loginQuestions.first;

  LoginField loginField = LoginField.username;

  late final FocusNode loginFieldFocus;

  Future<void> _login(
    BuildContext context,
    LoginField loginField,
    AuthenticationState state,
  ) async {
    if (formKey.currentState == null || !(formKey.currentState!).validate()) {
      return;
    }

    final credential = UserCredential(
      loginField: loginField,
      loginFieldValue: usernameController.text,
      password: passwordController.text,
      formHash: state.loginHash!.formHash,
      tsdmVerify: verifyCodeController.text,
      securityQuestion: _question == _loginQuestions.first
          ? null
          : SecurityQuestion(
              questionId: '${_loginQuestions.indexOf(_question)}',
              answer: answerController.text,
            ),
    );

    context
        .read<AuthenticationBloc>()
        .add(AuthenticationLoginRequested(credential));
  }

  Widget _buildForm(BuildContext context, AuthenticationState state) {
    // Only allow to press login button when got hash but not logged in.
    final pending = state.status != AuthenticationStatus.gotHash;
    final tr = context.t.loginPage;

    return Form(
      key: formKey,
      child: ListView(
        children: [
          Center(
            child: Text(
              tr.login,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          sizedBoxW12H12,
          TextFormField(
            autofocus: true,
            focusNode: loginFieldFocus,
            controller: usernameController,
            decoration: InputDecoration(
              // prefixIcon: const Icon(Icons.person),
              labelText: switch (loginField) {
                LoginField.username => tr.loginField.username,
                LoginField.uid => tr.loginField.uid,
                LoginField.email => tr.loginField.email,
              },
              // Follow M3 spec:
              // https://m3.material.io/components/text-fields/specs
              constraints: const BoxConstraints(maxHeight: specTextFieldHeight),
              prefix: DropdownButtonHideUnderline(
                child: DropdownButton<LoginField>(
                  value: loginField,
                  onChanged: (v) {
                    if (v == null) {
                      return;
                    }
                    setState(() {
                      loginField = v;
                    });
                    loginFieldFocus.requestFocus();
                  },
                  items: [
                    DropdownMenuItem(
                      value: LoginField.username,
                      child: Text(tr.loginField.username),
                    ),
                    DropdownMenuItem(
                      value: LoginField.uid,
                      child: Text(tr.loginField.uid),
                    ),
                    DropdownMenuItem(
                      value: LoginField.email,
                      child: Text(tr.loginField.email),
                    ),
                  ],
                ),
              ),
            ),
            validator: (v) => v!.trim().isNotEmpty ? null : tr.usernameEmpty,
          ),
          sizedBoxW12H12,
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.password),
              labelText: tr.password,
              suffixIcon: Focus(
                canRequestFocus: false,
                descendantsAreFocusable: false,
                child: IconButton(
                  icon: _showPassword
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
            ),
            obscureText: !_showPassword,
            validator: (v) => v!.trim().isNotEmpty ? null : tr.passwordEmpty,
          ),
          sizedBoxW12H12,
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: verifyCodeController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.pin),
                    labelText: tr.verifyCode,
                  ),
                  validator: (v) =>
                      v!.trim().isNotEmpty ? null : tr.verifyCodeEmpty,
                ),
              ),
              sizedBoxW12H12,
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: const CaptchaImage(),
              ),
            ],
          ),
          sizedBoxW12H12,
          InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.question_mark_outlined),
              labelText: tr.securityQuestion,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _question,
                isDense: true,
                onChanged: (newValue) {
                  if (newValue == null) {
                    return;
                  }
                  setState(() {
                    _question = newValue;
                  });
                },
                items: _loginQuestions.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          sizedBoxW12H12,
          TextFormField(
            controller: answerController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.question_answer_outlined),
              labelText: tr.answer,
              enabled: _question != _loginQuestions.first,
            ),
            validator: (v) =>
                _question == _loginQuestions.first || v!.trim().isNotEmpty
                    ? null
                    : tr.answerEmpty,
          ),
          sizedBoxW12H12,
          Row(
            children: [
              Expanded(
                child: DebounceFilledButton(
                  shouldDebounce: pending,
                  onPressed: () async => _login(context, loginField, state),
                  child: Text(tr.login),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    answerController = TextEditingController();
    verifyCodeController = TextEditingController();
    loginFieldFocus = FocusNode();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    answerController.dispose();
    verifyCodeController.dispose();
    loginFieldFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) async {
        if (state.status == AuthenticationStatus.success) {
          if (widget.redirectPath == null) {
            debug('login success, redirect back');
            Navigator.of(context).pop();
          } else {
            debug(
              'login success, redirect back to: path=${widget.redirectPath} '
              'with parameters=${widget.redirectPathParameters}, '
              'extra=${widget.redirectExtra}',
            );
            context.pushReplacementNamed(
              widget.redirectPath!,
              pathParameters: widget.redirectPathParameters ?? {},
              extra: widget.redirectExtra,
            );
          }
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: _buildForm,
      ),
    );
  }
}
