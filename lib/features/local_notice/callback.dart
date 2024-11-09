import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tsdm_client/features/local_notice/stream.dart';

/// Callback of the user tap on local notification.
void onLocalNotificationOpened(NotificationResponse resp) =>
    localNoticeStream.add(resp.payload);
