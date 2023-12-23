import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/small_providers.dart';

extension DateTimeExtension on DateTime {
  String yyyyMMDD() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  String elapsedTillNow(WidgetRef ref) {
    final duration = ref.read(serverDateTimeProvider).difference(this);
    return duration.inDays > 0
        ? '${duration.inDays}天'
        : duration.inHours > 0
            ? '${duration.inHours}小时'
            : duration.inMinutes > 0
                ? '${duration.inMinutes}分钟'
                : '${duration.inSeconds}秒';
  }
}
