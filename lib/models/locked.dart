import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:universal_html/html.dart' as uh;

@sealed
@immutable
class _LockedInfo {
  const _LockedInfo._();

  const factory _LockedInfo.points({
    required int requiredPoints,
    required int points,
  }) = _LockedWithPoints;

  const factory _LockedInfo.purchase({
    required int price,
    required int purchasedCount,
    required String tid,
    required String pid,
  }) = _LockedWithPurchase;
}

@immutable
final class _LockedWithPoints extends _LockedInfo {
  const _LockedWithPoints({
    required this.requiredPoints,
    required this.points,
  }) : super._();

  /// Points required to see this post area.
  final int requiredPoints;

  /// Points current user has.
  final int points;
}

@immutable
final class _LockedWithPurchase extends _LockedInfo {
  const _LockedWithPurchase(
      {required this.price,
      required this.purchasedCount,
      required this.tid,
      required this.pid})
      : super._();

  /// Thread id.
  final String? tid;

  /// Post id.
  final String? pid;

  /// Coins price to unlock.
  final int price;

  /// How many people have purchased.
  final int purchasedCount;
}

class Locked {
  /// Build a [Locked] from html node [element] where [element] is:
  /// <div class="locked">
  ///
  /// Currently only support locked by purchasing.
  Locked.fromLockDivNode(uh.Element element)
      : _info = _buildLockedFromNode(element);

  static final _re =
      RegExp(r'forum.php\?mod=misc&action=pay&tid=(?<tid>\d+)&pid=(?<pid>\d+)');

  final _LockedInfo? _info;

  bool get lockedWithPoints => _info != null && _info is _LockedWithPoints;

  bool get lockedWithPurchase => _info != null && _info is _LockedWithPurchase;

  String? get tid {
    if (_info == null) {
      return null;
    }
    if (_info is _LockedWithPurchase) {
      return (_info! as _LockedWithPurchase).tid;
    }
    return null;
  }

  String? get pid {
    if (_info == null) {
      return null;
    }
    if (_info is _LockedWithPurchase) {
      return (_info! as _LockedWithPurchase).pid;
    }
    return null;
  }

  int? get price {
    if (_info == null) {
      return null;
    }
    if (_info is _LockedWithPurchase) {
      return (_info! as _LockedWithPurchase).price;
    }
    return null;
  }

  int? get purchasedCount {
    if (_info == null) {
      return null;
    }
    if (_info is _LockedWithPurchase) {
      return (_info! as _LockedWithPurchase).purchasedCount;
    }
    return null;
  }

  int? get requiredPoints {
    if (_info == null) {
      return null;
    }
    if (_info is _LockedWithPoints) {
      return (_info! as _LockedWithPoints).requiredPoints;
    }
    return null;
  }

  int? get points {
    if (_info == null) {
      return null;
    }
    if (_info is _LockedWithPoints) {
      return (_info! as _LockedWithPoints).points;
    }
    return null;
  }

  /// Build from <div class="locked"> [element].
  static _LockedInfo? _buildLockedFromNode(uh.Element element) {
    final price = element
        .querySelector('strong')
        ?.firstEndDeepText()
        ?.split(' ')
        .firstOrNull
        ?.parseToInt();
    final purchasedCount = element
        .querySelector('em')
        ?.firstEndDeepText()
        ?.split(' ')
        .elementAtOrNull(1)
        ?.parseToInt();

    final targetString = element.querySelector('a')?.attributes['onclick'];

    final match = _re.firstMatch(targetString ?? '');

    final tid = match?.namedGroup('tid');
    final pid = match?.namedGroup('pid');

    if (tid == null || pid == null || price == null || purchasedCount == null) {
      /// Points type;
      final re = RegExp(r'高于 (?<requiredPoints>\d+).+当前积分为 (?<points>\d+)');
      final match = re.firstMatch(element.innerText);
      final requiredPoints = match?.namedGroup('requiredPoints')?.parseToInt();
      final points = match?.namedGroup('points')?.parseToInt();
      if (requiredPoints == null || points == null) {
        return null;
      }
      return _LockedInfo.points(
        requiredPoints: requiredPoints,
        points: points,
      );
    }

    return _LockedInfo.purchase(
      price: price,
      purchasedCount: purchasedCount,
      tid: tid,
      pid: pid,
    );
  }

  bool isValid() {
    return tid != null && pid != null;
  }
}
