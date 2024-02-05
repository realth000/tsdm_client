import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/points/models/points_change.dart';
import 'package:tsdm_client/features/points/repository/points_repository.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

part 'points_event.dart';
part 'points_state.dart';

/// Statistics emitter.
typedef PointsStatisticsEmitter = Emitter<PointsStatisticsState>;

/// Bloc of user points statistics page.
final class PointsStatisticsBloc
    extends Bloc<PointsStatisticsEvent, PointsStatisticsState> {
  /// Constructor.
  PointsStatisticsBloc({required PointsRepository pointsRepository})
      : _pointsRepository = pointsRepository,
        super(const PointsStatisticsState()) {
    on<PointsStatisticsRefreshRequired>(_onPointsStatisticsRefreshRequired);
  }

  final PointsRepository _pointsRepository;

  Future<void> _onPointsStatisticsRefreshRequired(
    PointsStatisticsRefreshRequired event,
    PointsStatisticsEmitter emit,
  ) async {
    emit(state.copyWith(status: PointsStatus.loading));
    try {
      final document = await _pointsRepository.fetchStatisticsPage();
      final result = _parseDocument(document);
      if (result == null) {
        emit(state.copyWith(status: PointsStatus.failed));
        return;
      }
      emit(
        state.copyWith(
          status: PointsStatus.success,
          pointsMap: result.$1,
          pointsRecentChangelog: result.$2,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      debug('failed to fetch points statistics page: $e');
      emit(state.copyWith(status: PointsStatus.failed));
    }
  }

  (Map<String, String>, List<PointsChange>)? _parseDocument(
    uh.Document document,
  ) {
    final rootNode = document.querySelector('div#ct_shell div.bm.bw0');
    if (rootNode == null) {
      debug('points change root node not found');
      return null;
    }
    final pointsMapEntries = rootNode
        .querySelectorAll('ul.creditl > li')
        .map((e) => e.parseLiEmNode())
        .whereType<(String, String)>()
        .map((e) => MapEntry(e.$1, e.$2));
    final pointsMap = Map<String, String>.fromEntries(pointsMapEntries);

    final tableNode = rootNode.querySelector('table.dt');
    if (tableNode == null) {
      debug('points change table not found');
      return null;
    }
    final pointsChangeList = _buildChangeListFromTable(tableNode);
    return (pointsMap, pointsChangeList);
  }

  /// Build a list of [PointsChange] from <table class="dt">
  List<PointsChange> _buildChangeListFromTable(uh.Element element) {
    final ret = element
        .querySelectorAll('table > tbody > tr')
        .skip(1)
        .map(PointsChange.fromTrNode)
        .whereType<PointsChange>()
        .toList();
    return ret;
  }
}
