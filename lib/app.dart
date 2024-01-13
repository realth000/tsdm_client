import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tsdm_client/features/forum/repository/forum_repository.dart';
import 'package:tsdm_client/features/theme/cubit/theme_cubit.dart';
import 'package:tsdm_client/features/upgrade/repository/upgrade_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/app_routes.dart';
import 'package:tsdm_client/shared/repositories/authentication_repository/authentication_repository.dart';
import 'package:tsdm_client/shared/repositories/cache_repository/cache_repository.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/shared/repositories/fragments_repository/fragments_repository.dart';
import 'package:tsdm_client/shared/repositories/profile_repository/profile_repository.dart';
import 'package:tsdm_client/shared/repositories/settings_repository/settings_repository.dart';
import 'package:tsdm_client/themes/app_themes.dart';

class App extends StatelessWidget {
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
        RepositoryProvider<CacheRepository>(
          create: (_) => CacheRepository(),
        ),
        RepositoryProvider<UpgradeRepository>(
          create: (_) => UpgradeRepository(),
        ),
        RepositoryProvider<ForumRepository>(
          create: (_) => ForumRepository(),
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
            final lightTheme = AppTheme.makeLight(accentColor);
            final darkTheme = AppTheme.makeDark(accentColor);

            return MaterialApp.router(
              title: 'tsdm_client',
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
