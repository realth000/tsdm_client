import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/features/home/cubit/home_cubit.dart';
import 'package:tsdm_client/features/home/widgets/home_navigation_bar.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/shared/repositories/settings_repository/settings_repository.dart';

/// Page of the homepage of the app.
class HomePage extends StatefulWidget {
  /// Constructor.
  const HomePage({
    required ForumHomeRepository forumHomeRepository,
    required this.showNavigationBar,
    required this.child,
    required this.inHome,
    super.key,
  }) : _forumHomeRepository = forumHomeRepository;

  /// Control to show the app level navigation bar or not.
  ///
  /// Only show in top pages.
  final bool showNavigationBar;

  /// Child widget, or call it the body widget.
  final Widget child;

  /// Flag indicating whether in home tab or not.
  ///
  /// This flag is consumed by homepage widget.
  final bool? inHome;

  final ForumHomeRepository _forumHomeRepository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Use this duration to limit the confirm time between the first exit app
  /// attempt and second real exit action.
  ///
  /// Maximum allowed duration between last time pop action triggered and
  /// current time.
  ///
  /// Means that if the user stayed more than this duration between two pop
  /// navigate action, the second one will be the confirm one and not pop back.
  static const exitConfirmDuration = Duration(seconds: 3);

  /// Record last time user try to exit the app.
  DateTime? lastPopTime;

  @override
  Widget build(BuildContext context) {
    Translations.of(context);
    return BlocProvider(
      create: (_) => HomeCubit()..setHomeState(inHome: widget.inHome),
      child: Builder(
        builder: (context) {
          context.read<HomeCubit>().setHomeState(inHome: widget.inHome);
          return RepositoryProvider.value(
            value: widget._forumHomeRepository,
            child: BackButtonListener(
              onBackButtonPressed: () async {
                if (!RepositoryProvider.of<SettingsRepository>(context)
                    .getDoublePressExit()) {
                  // Do NOT handle pop events on double press check is disabled.
                  return false;
                }
                if (context.canPop()) {
                  // Do NOT handle pop events on other pages.
                  return false;
                }
                final tr = context.t.home;
                final currentTime = DateTime.now();
                if (lastPopTime == null ||
                    currentTime.difference(lastPopTime!).inMilliseconds >
                        exitConfirmDuration.inMilliseconds) {
                  lastPopTime = currentTime;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tr.confirmExit),
                    ),
                  );
                  return true;
                }
                return false;
              },
              child: Scaffold(
                body: widget.child,
                bottomNavigationBar:
                    widget.showNavigationBar ? const HomeNavigationBar() : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
