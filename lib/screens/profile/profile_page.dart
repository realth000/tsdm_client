import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/utils/debug.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({this.uid, super.key});

  final String? uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          Text('Profile page uid=$uid'),
          ElevatedButton(
            child: const Text('logout'),
            onPressed: () async {
              final logoutResult =
                  await ref.read(authProvider.notifier).logout();
              if (logoutResult) {
                // Refresh root content.
                // We do not need the value return here, but if we use ref.invalidate()
                // the future will not execute until we reach pages that watching
                // rootContentProvider.
                //
                // There is no risk that provider refreshes multiple times before we
                // really use the cache in content.
                ref.invalidate(rootContentProvider);
              }
              debug('logout result: $logoutResult');
            },
          )
        ],
      ),
    );
  }
}
