import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/cache/bloc/image_cache_trigger_cubit.dart';
import 'package:tsdm_client/features/cache/repository/image_cache_repository.dart';
import 'package:tsdm_client/features/editor/repository/editor_repository.dart';
import 'package:tsdm_client/features/forum/repository/forum_repository.dart';
import 'package:tsdm_client/features/profile/repository/profile_repository.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/features/theme/cubit/theme_cubit.dart';
import 'package:tsdm_client/features/thread_visit_history/bloc/thread_visit_history_bloc.dart';
import 'package:tsdm_client/features/thread_visit_history/repository/thread_visit_history_repository.dart';
import 'package:tsdm_client/features/upgrade/repository/upgrade_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/app_routes.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/providers.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/shared/repositories/fragments_repository/fragments_repository.dart';
import 'package:tsdm_client/themes/app_themes.dart';

/// Main app for tsdm_client.
class App extends StatelessWidget {
  /// Constructor.
  const App(this.color, this.themeModeIndex, {super.key});

  /// Initial color value.
  final int color;

  /// Initial theme mode index.
  final int themeModeIndex;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationRepository>(
          create: (_) => AuthenticationRepository(),
        ),
        RepositoryProvider<ForumHomeRepository>(
          create: (_) => ForumHomeRepository(),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (_) => ProfileRepository(),
        ),
        RepositoryProvider<FragmentsRepository>(
          create: (_) => FragmentsRepository(),
        ),
        RepositoryProvider<UpgradeRepository>(
          create: (_) => UpgradeRepository(),
        ),
        RepositoryProvider<ForumRepository>(
          create: (_) => ForumRepository(),
        ),
        RepositoryProvider<EditorRepository>(
          create: (_) => EditorRepository()..loadEmojiFromServer(),
        ),
        RepositoryProvider<ImageCacheRepository>(
          create: (_) => ImageCacheRepository(
            getIt(),
            getIt.get<NetClientProvider>(instanceName: ServiceKeys.noCookie),
          ),
        ),
        RepositoryProvider<ImageCacheTriggerCubit>(
          create: (context) =>
              ImageCacheTriggerCubit(RepositoryProvider.of(context)),
        ),
        BlocProvider(
          create: (context) => SettingsBloc(
            fragmentsRepository:
                RepositoryProvider.of<FragmentsRepository>(context),
            settingsRepository: getIt.get<SettingsRepository>(),
          ),
        ),
        RepositoryProvider<ThreadVisitHistoryRepo>(
          create: (_) => ThreadVisitHistoryRepo(getIt.get<StorageProvider>()),
        ),
        BlocProvider(
          create: (context) =>
              ThreadVisitHistoryBloc(RepositoryProvider.of(context))
                ..add(const ThreadVisitHistoryFetchAllRequested()),
        ),
      ],
      child: BlocProvider(
        create: (context) => ThemeCubit(
          accentColor: color >= 0 ? Color(color) : null,
          themeModeIndex: themeModeIndex,
        ),
        child: BlocBuilder<ThemeCubit, ThemeState>(
          buildWhen: (prev, curr) => prev != curr,
          builder: (context, state) {
            final themeState = context.watch<ThemeCubit>().state;
            final accentColor = themeState.accentColor;
            final themeModeIndex = themeState.themeModeIndex;
            final lightTheme = AppTheme.makeLight(context, accentColor);
            final darkTheme = AppTheme.makeDark(context, accentColor);

            return MaterialApp.router(
              title: context.t.appName,
              routerConfig: router,
              locale: TranslationProvider.of(context).flutterLocale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: ThemeMode.values[themeModeIndex],
            );
          },
        ),
      ),
    );
  }
}
