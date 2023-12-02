import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:universal_html/html.dart' as uh;

class _LockedInfo {
  _LockedInfo({
    required this.price,
    required this.purchasedCount,
    required this.tid,
    required this.pid,
  });

  /// Coins price to unlock.
  final int price;

  /// How many people have purchased.
  final int purchasedCount;

  /// Thread id.
  final String? tid;

  /// Post id.
  final String? pid;
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

  final _LockedInfo _info;

  int get price => _info.price;

  int get purchasedCount => _info.purchasedCount;

  String? get tid => _info.tid;

  String? get pid => _info.pid;

  /// Build from <div class="locked"> [element].
  static _LockedInfo _buildLockedFromNode(uh.Element element) {
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

    return _LockedInfo(
      price: price ?? 0,
      purchasedCount: purchasedCount ?? 0,
      tid: tid,
      pid: pid,
    );
  }

  bool isValid() {
    return price > 0 && tid != null && pid != null;
  }
}
