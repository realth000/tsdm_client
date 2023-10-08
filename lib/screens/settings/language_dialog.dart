import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/settings_provider.dart';

class LanguageDialog extends ConsumerWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      scrollable: true,
      title: Text(t.settingsPage.appearanceSection.languages.selectLanguage),
      content: SingleChildScrollView(
        child: Column(
          children: [
            RadioListTile(
              title: Text(
                t.settingsPage.appearanceSection.languages.followSystem,
              ),
              onChanged: (value) async {
                if (value != null) {
                  LocaleSettings.useDeviceLocale();
                  await ref.read(appSettingsProvider.notifier).setLocale('');
                }
              },
              value: '',
              groupValue: ref.watch(appSettingsProvider).locale,
            ),
            ...AppLocale.values.map(
              (e) => RadioListTile(
                title: Text(e.languageTag),
                value: e.languageTag,
                groupValue: ref.watch(appSettingsProvider).locale,
                onChanged: (value) async {
                  LocaleSettings.setLocale(e);
                  await ref
                      .read(appSettingsProvider.notifier)
                      .setLocale(e.languageTag);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
