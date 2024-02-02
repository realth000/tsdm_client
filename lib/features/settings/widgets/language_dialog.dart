import 'package:flutter/material.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// Dialog to let user choose app locale.
class LanguageDialog extends StatelessWidget {
  /// Constructor.
  const LanguageDialog(this.currentLocale, {super.key});

  /// Current using locale.
  final String currentLocale;

  @override
  Widget build(BuildContext context) {
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
                  Navigator.of(context).pop((null, true));
                }
              },
              value: '',
              groupValue: currentLocale,
            ),
            ...AppLocale.values.map(
              (e) => RadioListTile(
                title: Text(e.translations.locale),
                value: e.languageTag,
                groupValue: currentLocale,
                onChanged: (value) async {
                  Navigator.of(context).pop((e, false));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
