import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/home/cubit/home_cubit.dart';
import 'package:tsdm_client/features/home/widgets/widgets.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_homeorum_home_repository.dart';
import 'package:tsdm_client/utils/show_toast.dart';

const _drawerWidth = 250.0;

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

  Widget _buildDrawerBody(BuildContext context) => Scaffold(
        body: Row(
          children: [
            if (widget.showNavigationBar)
              Column(
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    height: 100,
                    width: _drawerWidth,
                    child: Center(
                      child: Text(
                        context.t.appName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _drawerWidth,
                      ),
                      child: const HomeNavigationDrawer(),
                    ),
                  ),
                ],
              ),
            Expanded(child: widget.child),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    Translations.of(context);
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: Builder(
        builder: (context) {
          final Widget child;
          if (ResponsiveBreakpoints.of(context)
              .largerThan(WindowSize.expanded.name)) {
            child = _buildDrawerBody(context);
          } else if (ResponsiveBreakpoints.of(context)
              .largerThan(WindowSize.compact.name)) {
            child = Scaffold(
              body: Row(
                children: [
                  if (widget.showNavigationBar) const HomeNavigationRail(),
                  Expanded(child: widget.child),
                ],
              ),
            );
          } else {
            child = Scaffold(
              body: widget.child,
              bottomNavigationBar:
                  widget.showNavigationBar ? const HomeNavigationBar() : null,
            );
          }

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
                  showSnackBar(context: context, message: tr.confirmExit);
                  return true;
                }
                return false;
              },
              child: child,
            ),
          );
        },
      ),
    );
  }
}
