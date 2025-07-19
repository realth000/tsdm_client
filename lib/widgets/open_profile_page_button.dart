import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';

/// Buton provides entry to current users' profile.
class OpenProfilePageButton extends StatefulWidget {
  /// Constructor.
  const OpenProfilePageButton({this.icon, super.key});

  /// Icon used in button.
  final Icon? icon;

  @override
  State<OpenProfilePageButton> createState() => _OpenProfilePageButtonState();
}

class _OpenProfilePageButtonState extends State<OpenProfilePageButton> {
  @override
  Widget build(BuildContext context) {
    final isLogin = context.select<AuthenticationRepository, bool>((repo) => repo.currentUser != null);
    return IconButton(
      icon: widget.icon ?? const Icon(Symbols.user_attributes),
      tooltip: context.t.profilePage.title,
      onPressed: isLogin ? () async => context.pushNamed(ScreenPaths.profile) : null,
    );
  }
}
