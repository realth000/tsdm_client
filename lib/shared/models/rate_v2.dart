part of 'models.dart';

/// A group of score.
final class ScoreMap {
  /// Constructor.
  const ScoreMap(this.scoreMap);

  /// All rated score.
  final Map<String, int> scoreMap;
}

final class _ScoreMapMapper extends SimpleMapper<ScoreMap> with LoggerMixin {
  const _ScoreMapMapper();

  @override
  ScoreMap decode(Object value) {
    if (value is! List<String>) {
      error('invalid score map type: ${value.runtimeType}');
      return const ScoreMap({});
    }

    final entries = value
        .map((e) => e.split(':'))
        .where((e) => e.length == 2)
        .map((e) => MapEntry(e.first, int.tryParse(e.elementAt(1))))
        .whereType<MapEntry<String, int>>();

    return ScoreMap(Map.fromEntries(entries));
  }

  @override
  Object? encode(ScoreMap self) {
    return self.scoreMap.entries.map((e) => '${e.key}:${e.value}').toList();
  }
}

/// A Single rate.
@MappableClass(includeCustomMappers: [_ScoreMapMapper()])
final class SingleRateV2 with SingleRateV2Mappable {
  /// Constructor.
  const SingleRateV2({
    required this.uid,
    required this.username,
    required this.status,
    required this.score,
    required this.reason,
  });

  /// User id of the user who did the rate action.
  final int uid;

  /// Username of the user who did the rate action.
  final String username;

  /// Status.
  ///
  /// Just keep it here.
  final int status;

  /// All score;
  final ScoreMap score;

  /// Rate reason.
  final String reason;
}
