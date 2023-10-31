import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/utils/git_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.settingsPage.othersSection.about),
      ),
      body: ListView(
        children: [
          Image.asset(
            './assets/images/tsdm_client.png',
            width: 240,
            height: 240,
          ),
          const SizedBox(width: 10, height: 10),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18),
            leading: const Icon(Icons.contact_support_outlined),
            title: Text(context.t.aboutPage.whatIsThis),
            subtitle: Text(context.t.aboutPage.description),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18),
            leading: const Icon(Icons.app_shortcut_outlined),
            title: Text(context.t.aboutPage.packageName),
            subtitle: const Text('kzs.th000.tsdm_client'),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18),
            leading: const Icon(Icons.terminal_outlined),
            title: Text(context.t.aboutPage.version),
            subtitle: const Text(
              '$gitCommitRevisionShort ($gitCommitTimeYear-$gitCommitTimeMonth-$gitCommitTimeDay)',
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18),
            leading: const Icon(Icons.home_max_outlined),
            title: Text(context.t.aboutPage.forumHomepage),
            subtitle: const Text(baseUrl),
            trailing: const Icon(Icons.launch_outlined),
            onTap: () async {
              await launchUrl(
                Uri.parse(baseUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18),
            leading: const Icon(Icons.home_outlined),
            title: Text(context.t.aboutPage.homepage),
            subtitle: const Text('https://github.com/realth000/tsdm_client'),
            trailing: const Icon(Icons.launch_outlined),
            onTap: () async {
              await launchUrl(
                Uri.parse('https://github.com/realth000/tsdm_client'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18),
            leading: const Icon(Icons.flutter_dash_outlined),
            title: Text(context.t.aboutPage.flutterVersion),
            subtitle: const Text(
              '$flutterVersion ($flutterChannel) - $flutterFrameworkRevision',
            ),
            trailing: const Icon(Icons.launch_outlined),
            onTap: () async {
              await launchUrl(
                Uri.parse('https://flutter.dev/'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18),
            leading: const Icon(Icons.foundation_outlined),
            title: Text(context.t.aboutPage.dartVersion),
            subtitle: const Text(dartVersion),
            trailing: const Icon(Icons.launch_outlined),
            onTap: () async {
              await launchUrl(
                Uri.parse('https://dart.dev/'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18),
            leading: const Icon(Icons.balance_outlined),
            title: Text(context.t.aboutPage.license),
            subtitle: const Text('MIT license'),
          )
        ],
      ),
    );
  }
}
