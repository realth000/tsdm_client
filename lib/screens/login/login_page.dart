import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({this.redirectBackRoute, super.key});

  final String? redirectBackRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text('login page with redirectBackRoute=$redirectBackRoute');
  }
}
