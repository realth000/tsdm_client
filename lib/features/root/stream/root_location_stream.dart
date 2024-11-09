import 'dart:async';

import 'package:tsdm_client/features/root/models/models.dart';

/// Global stream for bridging current page location updates.
final StreamController<RootLocationEvent> rootLocationStream =
    StreamController<RootLocationEvent>.broadcast();
