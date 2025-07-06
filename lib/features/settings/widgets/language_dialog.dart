import 'package:flutter/material.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';

/// Dialog to let user choose app locale.
class LanguageDialog extends StatelessWidget {
  /// Constructor.
  const LanguageDialog(this.currentLocale, {super.key});

  /// Current using locale.
  final String currentLocale;

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog.sync(
      title: Text(t.settingsPage.appearanceSection.languages.selectLanguage),
      content: Column(
        children: [
          RadioListTile(
            title: Text(t.settingsPage.appearanceSection.languages.followSystem),
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
              // TODO: Check if is caused by lazy loading.
              // Traditional Chinese language tag is displayed as "English".
              title: // Text(e.translations.locale),
              Text(switch (e.languageTag) {
                'en' => 'English',
                'zh-CN' => '简体中文',
                'zh-TW' => '繁體中文',
                final v => throw UnimplementedError(
                  'unsupported '
                  'language tag $v',
                ),
              }),
              value: e.languageTag,
              groupValue: currentLocale,
              onChanged: (value) async {
                Navigator.of(context).pop((e, false));
              },
            ),
          ),
        ],
      ),
    );
  }
}
