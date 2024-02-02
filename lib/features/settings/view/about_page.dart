import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/git_info.dart';
import 'package:tsdm_client/widgets/section_list_tile.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page to show the about information.
class AboutPage extends StatelessWidget {
  /// Constructor.
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.settingsPage.othersSection.about),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            onPressed: () async {
              const data = '''
## Info

* Version: $appFullVersion
* Flutter: $flutterVersion $flutterChannel ($flutterFrameworkRevision)
* Dart: $dartVersion
''';
              await Clipboard.setData(const ClipboardData(text: data));
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.t.aboutPage.copiedToClipboard),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Image.asset(assetsLogoPath, width: 192, height: 192),
          sizedBoxW10H10,
          SectionListTile(
            leading: const Icon(Icons.contact_support_outlined),
            title: Text(context.t.aboutPage.whatIsThis),
            subtitle: Text(context.t.aboutPage.description),
          ),
          SectionListTile(
            leading: const Icon(Icons.app_shortcut_outlined),
            title: Text(context.t.aboutPage.packageName),
            subtitle: const Text('kzs.th000.tsdm_client'),
          ),
          SectionListTile(
            leading: const Icon(Icons.terminal_outlined),
            title: Text(context.t.aboutPage.version),
            subtitle: const Text(appFullVersion),
          ),
          SectionListTile(
            leading: const Icon(Icons.home_max_outlined),
            title: Text(context.t.aboutPage.forumHomepage),
            subtitle: const Text(baseUrl),
            onTap: () async {
              await launchUrl(
                Uri.parse(baseUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          SectionListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text(context.t.aboutPage.homepage),
            subtitle: const Text('https://github.com/realth000/tsdm_client'),
            onTap: () async {
              await launchUrl(
                Uri.parse('https://github.com/realth000/tsdm_client'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          SectionListTile(
            leading: const Icon(Icons.flutter_dash_outlined),
            title: Text(context.t.aboutPage.flutterVersion),
            subtitle: const Text(
              '$flutterVersion ($flutterChannel) - $flutterFrameworkRevision',
            ),
            onTap: () async {
              await launchUrl(
                Uri.parse('https://flutter.dev/'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          SectionListTile(
            leading: const Icon(Icons.foundation_outlined),
            title: Text(context.t.aboutPage.dartVersion),
            subtitle: const Text(dartVersion),
            onTap: () async {
              await launchUrl(
                Uri.parse('https://dart.dev/'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          SectionListTile(
            leading: const Icon(Icons.balance_outlined),
            title: Text(context.t.aboutPage.license),
            subtitle: const Text('MIT license'),
            onTap: () async => context.pushNamed(ScreenPaths.license),
          ),
        ],
      ),
    );
  }
}
