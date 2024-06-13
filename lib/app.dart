import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/cache/bloc/image_cache_trigger_cubit.dart';
import 'package:tsdm_client/features/cache/repository/image_cache_repository.dart';
import 'package:tsdm_client/features/editor/repository/editor_repository.dart';
import 'package:tsdm_client/features/forum/repository/forum_repository.dart';
import 'package:tsdm_client/features/theme/cubit/theme_cubit.dart';
import 'package:tsdm_client/features/upgrade/repository/upgrade_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/app_routes.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/shared/repositories/fragments_repository/fragments_repository.dart';
import 'package:tsdm_client/shared/repositories/profile_repository/profile_repository.dart';
import 'package:tsdm_client/shared/repositories/settings_repository/settings_repository.dart';
import 'package:tsdm_client/themes/app_themes.dart';

/// Main app for tsdm_client.
class App extends StatelessWidget {
  /// Constructor.
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingsRepository>(
          create: (_) => SettingsRepository(),
        ),
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
          create: (_) => ImageCacheRepository(getIt(), getIt()),
        ),
        RepositoryProvider<ImageCacheTriggerCubit>(
          create: (context) =>
              ImageCacheTriggerCubit(RepositoryProvider.of(context)),
        ),
      ],
      child: BlocProvider(
        create: (context) {
          final re = RepositoryProvider.of<SettingsRepository>(context);
          final color = re.getAccentColorValue();
          final theme = re.getThemeMode();
          return ThemeCubit(
            accentColor: color >= 0 ? Color(color) : null,
            themeModeIndex: theme,
          );
        },
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
