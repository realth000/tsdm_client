import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
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
              debug('logout result: $logoutResult');
            },
          )
        ],
      ),
    );
  }
}
