import 'package:flutter/foundation.dart';

void debug(Object? object) {
  if (kDebugMode) {
    print('[debug]: $object');
  }
}
