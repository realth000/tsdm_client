import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/features/home/cubit/home_cubit.dart';
import 'package:tsdm_client/features/home/widgets/home_navigation_bar.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';

/// Page of the homepage of the app.
class HomePage extends StatelessWidget {
  const HomePage({
    required ForumHomeRepository forumHomeRepository,
    required this.showNavigationBar,
    required this.child,
    super.key,
  }) : _forumHomeRepository = forumHomeRepository;

  final bool showNavigationBar;

  final Widget child;

  final ForumHomeRepository _forumHomeRepository;

  @override
  Widget build(BuildContext context) {
    Translations.of(context);
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: RepositoryProvider.value(
        value: _forumHomeRepository,
        child: Builder(builder: (context) {
          return Scaffold(
            body: child,
            bottomNavigationBar:
                showNavigationBar ? const HomeNavigationBar() : null,
          );
        }),
      ),
    );
  }
}
