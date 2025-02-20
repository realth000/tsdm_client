import 'dart:async';

/// A global stream acts like a bridge
final StreamController<String?> localNoticeStream = StreamController<String?>.broadcast();
