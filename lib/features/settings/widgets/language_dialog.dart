import 'package:flutter/material.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog(this.currentLocale, {super.key});

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
