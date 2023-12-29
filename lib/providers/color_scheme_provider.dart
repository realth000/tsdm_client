import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/providers/settings_provider.dart';

part '../generated/providers/color_scheme_provider.g.dart';

@Riverpod(dependencies: [AppSettings])
class AppColorScheme extends _$AppColorScheme {
  @override
  Color? build() {
    final color = ref.read(appSettingsProvider).accentColor;
    if (color < 0) {
      return null;
    }
    return Color(color);
  }

  Future<void> setAccentColor(Color color) async {
    await ref.read(appSettingsProvider.notifier).setAccentColor(color);
    state = color;
  }

  Future<void> clearAccentColor() async {
    await ref.read(appSettingsProvider.notifier).clearAccentColor();
    state = null;
  }
}
