import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/points/models/models.dart';
import 'package:tsdm_client/features/points/repository/model/models.dart';
import 'package:tsdm_client/features/points/repository/points_repository.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;

part 'points_bloc.mapper.dart';
part 'points_event.dart';
part 'points_state.dart';

/// Statistics emitter.
typedef PointsStatisticsEmitter = Emitter<PointsStatisticsState>;

/// Changelog emitter.
typedef PointsChangelogEmitter = Emitter<PointsChangelogState>;

/// Bloc of user points statistics page.
final class PointsStatisticsBloc
    extends Bloc<PointsStatisticsEvent, PointsStatisticsState>
    with LoggerMixin {
  /// Constructor.
  PointsStatisticsBloc({required PointsRepository pointsRepository})
      : _pointsRepository = pointsRepository,
        super(const PointsStatisticsState()) {
    on<PointsStatisticsRefreshRequested>(_onPointsStatisticsRefreshRequested);
  }

  final PointsRepository _pointsRepository;

  Future<void> _onPointsStatisticsRefreshRequested(
    PointsStatisticsRefreshRequested event,
    PointsStatisticsEmitter emit,
  ) async {
    emit(state.copyWith(status: PointsStatus.loading));
    await _pointsRepository.fetchStatisticsPage().match(
      (e) {
        handle(e);
        error('failed to fetch points statistics page: $e');
        emit(state.copyWith(status: PointsStatus.failed));
      },
      (v) {
        final document = v;
        final result = _parseDocument(document);
        if (result == null) {
          emit(state.copyWith(status: PointsStatus.failed));
          return;
        }
        emit(
          state.copyWith(
            status: PointsStatus.success,
            pointsMap: result.$1,
            recentChangelog: result.$2,
          ),
        );
      },
    ).run();
  }

  (Map<String, String>, List<PointsChange>)? _parseDocument(
    uh.Document document,
  ) {
    final rootNode = document.querySelector('div#ct_shell div.bm.bw0');
    if (rootNode == null) {
      error('points change root node not found');
      return null;
    }
    final pointsMapEntries = rootNode
        .querySelectorAll('ul.creditl > li')
        .map((e) => e.parseLiEmNode(second: true))
        .whereType<(String, String)>()
        .map((e) => MapEntry(e.$1.split(':').first.trim(), e.$2.trim()));
    final pointsMap = Map<String, String>.fromEntries(pointsMapEntries);

    final tableNode = rootNode.querySelector('table.dt');
    if (tableNode == null) {
      error('points change table not found');
      return null;
    }
    final pointsChangeList = _buildChangeListFromTable(tableNode);
    return (pointsMap, pointsChangeList);
  }
}

/// Bloc of the points changelog page.
final class PointsChangelogBloc
    extends Bloc<PointsChangelogEvent, PointsChangelogState> with LoggerMixin {
  /// Constructor.
  PointsChangelogBloc({required PointsRepository pointsRepository})
      : _pointsRepository = pointsRepository,
        super(const PointsChangelogState()) {
    on<PointsChangelogRefreshRequested>(_onPointsChangelogRefreshRequested);
    on<PointsChangelogLoadMoreRequested>(_onPointsChangelogLoadMoreRequested);
    on<PointsChangelogQueryRequested>(_onPointsChangelogQueryRequested);
  }

  /// Repository of changelog.
  final PointsRepository _pointsRepository;

  Future<void> _onPointsChangelogRefreshRequested(
    PointsChangelogRefreshRequested event,
    PointsChangelogEmitter emit,
  ) async {
    emit(
      state.copyWith(
        status: PointsStatus.loading,
        fullChangelog: [],
      ),
    );
    await _pointsRepository
        .fetchChangelogPage(state.parameter.copyWith(pageNumber: 1))
        .match(
      (e) {
        handle(e);
        error('failed to refresh changelog tab: $e');
        emit(state.copyWith(status: PointsStatus.failed));
      },
      (v) {
        final document = v;
        final s = _parseDocument(document, state.currentPage);
        final allParameters = _parseAllParameters(document);
        emit(s.copyWith(allParameters: allParameters));
      },
    ).run();
  }

  Future<void> _onPointsChangelogLoadMoreRequested(
    PointsChangelogLoadMoreRequested event,
    PointsChangelogEmitter emit,
  ) async {
    await _pointsRepository
        .fetchChangelogPage(
      state.parameter.copyWith(pageNumber: state.currentPage + 1),
    )
        .match(
      (e) {
        handle(e);
        error('failed to load more points changelog: $e');
        emit(state.copyWith(status: PointsStatus.failed));
      },
      (v) => emit(_parseDocument(v, event.pageNumber)),
    ).run();
  }

  Future<void> _onPointsChangelogQueryRequested(
    PointsChangelogQueryRequested event,
    PointsChangelogEmitter emit,
  ) async {
    emit(
      state.copyWith(
        status: PointsStatus.loading,
        fullChangelog: [],
        parameter: event.parameter,
      ),
    );
    await _pointsRepository
        .fetchChangelogPage(state.parameter.copyWith(pageNumber: 1))
        .match((e) {
      error('failed to refresh changelog tab: $e');
      emit(state.copyWith(status: PointsStatus.failed));
    }, (v) {
      final document = v;
      final s = _parseDocument(document, state.currentPage);
      final allParameters = _parseAllParameters(document);
      emit(s.copyWith(allParameters: allParameters));
    }).run();
  }

  ChangelogAllParameters _parseAllParameters(uh.Document document) {
    // These options seem invisible in browser but exist.
    // <select id="optype" name="optype">
    //   <option value="">Choose</option>
    //   <option value="TRC">Task</option>
    //   ...
    // </select>
    final extTypeList = document
        .querySelectorAll('select#exttype > option')
        .where((e) => e.attributes['value'] != null)
        .map(
          (e) => ChangelogPointsType(
            name: e.innerText.trim(),
            extType: e.attributes['value']!,
          ),
        )
        .toList();
    final optTypeList = document
        .querySelectorAll('select#optype > option')
        .where((e) => e.attributes['value'] != null)
        .map(
          (e) => ChangelogOperationType(
            name: e.innerText.trim(),
            operation: e.attributes['value']!,
          ),
        )
        .toList();

    final changeTypeList = document
        .querySelectorAll('select#income > option')
        .where((e) => e.attributes['value'] != null)
        .map(
          (e) => ChangelogChangeType(
            name: e.innerText.trim(),
            changeType: e.attributes['value']!,
          ),
        )
        .toList();

    return ChangelogAllParameters(
      extTypeList: extTypeList,
      operationTypeList: optTypeList,
      changeTypeList: changeTypeList,
    );
  }

  /// parse [document] into state.
  ///
  /// * [pageNumber] is the current recorded current page number. Used as a
  /// fallback page number if current page or total pages not found in document.
  PointsChangelogState _parseDocument(uh.Document document, int pageNumber) {
    final tableNode = document.querySelector('table.dt');
    if (tableNode == null) {
      error('points change table not found');
      return state.copyWith(status: PointsStatus.failed);
    }
    final changeList = _buildChangeListFromTable(tableNode);
    final currentPage = document.currentPage() ?? pageNumber;
    final totalPages = document.totalPages() ?? pageNumber;
    return state.copyWith(
      status: PointsStatus.success,
      fullChangelog: [...state.fullChangelog, ...changeList],
      currentPage: currentPage,
      totalPages: totalPages,
    );
  }
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
