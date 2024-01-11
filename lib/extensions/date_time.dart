// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:tsdm_client/providers/small_providers.dart';

import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/server_time_provider/sevrer_time_provider.dart';

extension DateTimeExtension on DateTime {
  String yyyyMMDD() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  String elapsedTillNow() {
    final duration = getIt.get<ServerTimeProvider>().time.difference(this);
    return duration.inDays > 0
        ? '${duration.inDays}天'
        : duration.inHours > 0
            ? '${duration.inHours}小时'
            : duration.inMinutes > 0
                ? '${duration.inMinutes}分钟'
                : '${duration.inSeconds}秒';
  }
}
