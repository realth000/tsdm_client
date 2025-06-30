import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/features/rate/models/models.dart';
import 'package:tsdm_client/features/rate/repository/rate_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'rate_log_cubit.mapper.dart';
part 'rate_log_state.dart';

/// Cubit of rate log.
final class RateLogCubit extends Cubit<RateLogState> with LoggerMixin {
  /// Constructor.
  RateLogCubit(this._repo) : super(const RateLogState());

  final RateRepository _repo;

  /// Fetch rate log with give post id [pid] and thread id [tid].
  Future<void> fetchLog({required String tid, required String pid}) async {
    emit(state.copyWith(status: RateLogStatus.loading));
    (await _repo.fetchRateLog(tid: tid, pid: pid).run()).match(
      (e) {
        handle(e);
        emit(state.copyWith(status: RateLogStatus.failure));
      },
      (v) => emit(state.copyWith(status: RateLogStatus.success, logItems: v, accumulatedLogItems: _accumulateItems(v))),
    );
  }

  List<RateLogAccumulatedItem> _accumulateItems(List<RateLogItem> items) {
    RateLogAccumulatedItem? tmpItem;
    final accumulatedItems = <RateLogAccumulatedItem>[];
    for (final item in items) {
      if (tmpItem == null) {
        tmpItem = RateLogAccumulatedItem(
          attrMap: {item.attrName: item.attrValue},
          username: item.username,
          uid: item.uid,
          firstRateTime: item.time,
          lastRateTime: item.time,
          reason: item.reason,
        );

        continue;
      }

      // Accumulate if possible.

      if (tmpItem.uid == item.uid &&
          tmpItem.username == item.username &&
          (tmpItem.reason == item.reason || item.reason.isEmpty || tmpItem.reason.isEmpty)) {
        // Accumulate to current one.
        if (tmpItem.attrMap.containsKey(item.attrName)) {
          tmpItem.attrMap[item.attrName] = item.attrValue + tmpItem.attrMap[item.attrName]!;
        } else {
          tmpItem.attrMap[item.attrName] = item.attrValue;
        }

        if (tmpItem.firstRateTime.isAfter(item.time)) {
          tmpItem = tmpItem.copyWith(firstRateTime: item.time);
        }

        if (tmpItem.lastRateTime.isBefore(item.time)) {
          tmpItem = tmpItem.copyWith(lastRateTime: item.time);
        }

        if (tmpItem.reason.isEmpty && item.reason.isNotEmpty) {
          tmpItem = tmpItem.copyWith(reason: item.reason);
        }
      } else {
        // New one.
        accumulatedItems.add(tmpItem);
        tmpItem = RateLogAccumulatedItem(
          attrMap: {item.attrName: item.attrValue},
          username: item.username,
          uid: item.uid,
          firstRateTime: item.time,
          lastRateTime: item.time,
          reason: item.reason,
        );
      }
    }

    if (tmpItem != null) {
      // Don't forget the last one.
      accumulatedItems.add(tmpItem);
    }

    return accumulatedItems;
  }
}
