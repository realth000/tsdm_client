import 'package:hooks_riverpod/hooks_riverpod.dart';

final appNavigationBarIndexProvider = StateProvider((ref) => 0);

final isCheckingInProvider = StateProvider((ref) => false);

final topicsTabBarIndexProvider = StateProvider((ref) => 0);
