import 'package:flutter/material.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';
import 'package:tsdm_client/widgets/selectable_list_tile.dart';

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
          SelectableListTile(
            title: Text(t.settingsPage.appearanceSection.languages.followSystem),
            selected: currentLocale == '',
            onTap: () async => Navigator.of(context).pop((null, true)),
          ),
          ...AppLocale.values.map(
            (e) => SelectableListTile(
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
              selected: currentLocale == e.languageTag,
              onTap: () async => Navigator.of(context).pop((e, false)),
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
