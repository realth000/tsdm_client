import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({required this.uid, super.key});

  final String? uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text('Profile page uid=$uid');
  }
}
