part of 'models.dart';

sealed class _LockedInfo extends Equatable {
  const _LockedInfo._();

  const factory _LockedInfo.points({required int requiredPoints, required int? points}) = _LockedWithPoints;

  const factory _LockedInfo.purchase({
    required int price,
    required int? purchasedCount,
    required String tid,
    required String pid,
  }) = _LockedWithPurchase;

  const factory _LockedInfo.reply() = _LockedWithReply;

  const factory _LockedInfo.author() = _LockedWithAuthor;

  const factory _LockedInfo.banned() = _LockedWithBlocked;

  const factory _LockedInfo.sale({required int price, required int salesCount, required String tid}) =
      _LockedWithSale._;

  @override
  List<Object?> get props => [];
}

/// This section is invisible because current user does not have enough points.
final class _LockedWithPoints extends _LockedInfo {
  const _LockedWithPoints({required this.requiredPoints, required this.points}) : super._();

  /// Points required to see this post area.
  final int requiredPoints;

  /// Points current user has.
  final int? points;

  @override
  List<Object?> get props => [requiredPoints, points];
}

/// This section needs purchase to be visible.
final class _LockedWithPurchase extends _LockedInfo {
  const _LockedWithPurchase({required this.price, required this.purchasedCount, required this.tid, required this.pid})
    : super._();

  /// Thread id.
  final String? tid;

  /// Post id.
  final String? pid;

  /// Coins price to unlock.
  final int price;

  /// How many people have purchased.
  ///
  /// May be null.
  final int? purchasedCount;

  @override
  List<Object?> get props => [tid, pid, price, purchasedCount];
}

/// This section is locked with purchase but the current user is the provider of thread so content are different.
///
/// Contains sale status:
///
/// 1. Price
/// 2. Sales counts.
/// 3. Url to sale history.
final class _LockedWithSale extends _LockedInfo {
  /// Constructor.
  const _LockedWithSale._({required this.price, required this.salesCount, required this.tid}) : super._();

  /// Price of the locked contents.
  final int price;

  /// Users count of sales.
  final int salesCount;

  /// Thread if of current thread, to format log history url.
  final String tid;

  @override
  List<Object?> get props => [price, salesCount, tid];
}

/// This section needs reply to be visible.
final class _LockedWithReply extends _LockedInfo {
  const _LockedWithReply() : super._();
}

/// This section is only visible to the author of current thread.
final class _LockedWithAuthor extends _LockedInfo {
  const _LockedWithAuthor() : super._();
}

/// This section is blocked by admin or moderator.
final class _LockedWithBlocked extends _LockedInfo {
  const _LockedWithBlocked() : super._();
}

/// Describe a locked area in `Post`.
///
/// Different types may be locked with different reasons:
/// * [_LockedWithPoints] : Requires the viewer to have at least xxx points.
/// * [_LockedWithPurchase] : Requires the viewer to purchase.
/// * [_LockedWithReply] : Requires the view to reply.
/// * [_LockedWithAuthor] : Only visible to the author and forum moderator.
/// * [_LockedWithSale] : Thread contains sales action, current user provided it.
class Locked extends Equatable {
  /// Build a [Locked] from html node [element] where [element] is:
  /// <div class="locked">
  ///
  /// Currently only support locked by purchasing.
  ///
  /// For better layout, when a section is locked with points and inside
  /// "postmessage", we should only build it inside "postmessage" too,
  /// [allowWithPoints] is the flag caller shall specify.
  Locked.fromLockDivNode(
    uh.Element element, {
    bool allowWithPoints = true,
    bool allowWithPurchase = true,
    bool allowWithReply = true,
    bool allowWithAuthor = true,
    bool allowWithBlocked = true,
    bool allowWithSales = true,
  }) : _info = _buildLockedFromNode(
         element,
         allowWithPoints: allowWithPoints,
         allowWithPurchase: allowWithPurchase,
         allowWithReply: allowWithReply,
         allowWithAuthor: allowWithAuthor,
         allowWithBlocked: allowWithBlocked,
         allowWithSale: allowWithSales,
       );

  static final _purchareRe = RegExp(r'forum.php\?mod=misc&action=pay&tid=(?<tid>\d+)&pid=(?<pid>\d+)');

  final _LockedInfo? _info;

  /// Is locked with view's points.
  bool get lockedWithPoints => _info != null && _info is _LockedWithPoints;

  /// Is locked with purchase.
  bool get lockedWithPurchase => _info != null && _info is _LockedWithPurchase;

  /// Is locked with reply.
  bool get lockedWithReply => _info != null && _info is _LockedWithReply;

  /// Is it only visible to the author and forum moderator.
  bool get lockedWithAuthor => _info != null && _info is _LockedWithAuthor;

  /// Is it blocked by moderator.
  bool get lockedWithBlocked => _info != null && _info is _LockedWithBlocked;

  /// Is it locked with sale action.
  bool get lockedWithSale => _info != null && _info is _LockedWithSale;

  /// Get the tid of current locked model.
  String? get tid {
    if (_info == null) {
      return null;
    }
    if (_info is _LockedWithPurchase) {
      return _info.tid;
    }
    if (_info is _LockedWithSale) {
      return _info.tid;
    }
    return null;
  }

  /// Get the pid of current locked model.
  String? get pid {
    if (_info == null) {
      return null;
    }
    if (_info is _LockedWithPurchase) {
      return _info.pid;
    }
    return null;
  }

  /// Get the price of current locked model.
  ///
  /// Only not null when locked with purchase.
  int? get price {
    if (_info == null) {
      return null;
    }
    if (_info is _LockedWithPurchase) {
      return _info.price;
    }
    if (_info is _LockedWithSale) {
      return _info.price;
    }
    return null;
  }

  /// Get the purchase times count.
  ///
  /// Only not null when locked with purchase.
  int? get purchasedCount {
    if (_info == null) {
      return null;
    }
    if (_info is _LockedWithPurchase) {
      return _info.purchasedCount;
    }
    if (_info is _LockedWithSale) {
      return _info.salesCount;
    }
    return null;
  }

  /// Get the required points to view this area.
  ///
  /// Only not null when locked with points.
  int? get requiredPoints {
    if (_info == null) {
      return null;
    }
    if (_info is _LockedWithPoints) {
      return _info.requiredPoints;
    }
    return null;
  }

  /// Get the points that the current user has.
  ///
  /// Only not null when locked with points.
  int? get points {
    if (_info == null) {
      return null;
    }
    if (_info is _LockedWithPoints) {
      return _info.points;
    }
    return null;
  }

  /// Build from <div class="locked"> [element].
  static _LockedInfo? _buildLockedFromNode(
    uh.Element element, {
    required bool allowWithPoints,
    required bool allowWithPurchase,
    required bool allowWithReply,
    required bool allowWithAuthor,
    required bool allowWithBlocked,
    required bool allowWithSale,
  }) {
    if (allowWithAuthor && element.childNodes.length == 1 && (element.childNodes[0].text?.contains('仅作者可见') ?? false)) {
      return const _LockedInfo.author();
    }

    // Check if is locked with reply.
    if (allowWithReply && element.innerText.contains('查看本帖隐藏内容请回复')) {
      return const _LockedInfo.reply();
    }

    final price = element.querySelector('strong')?.firstEndDeepText()?.split(' ').firstOrNull?.parseToInt();
    // For other users on purchase side.
    final purchasedCount = element.querySelector('em')?.firstEndDeepText()?.split(' ').elementAtOrNull(1)?.parseToInt();

    // Check for locked with purchase.
    final purchaseMatch = _purchareRe.firstMatch(element.querySelector('a')?.attributes['onclick'] ?? '');
    final purchaseTid = purchaseMatch?.namedGroup('tid');
    final purchasePid = purchaseMatch?.namedGroup('pid');
    if (price != null && purchaseTid != null && purchasePid != null) {
      // Locked with purchase.
      if (!allowWithPurchase) {
        return null;
      }

      return _LockedInfo.purchase(price: price, purchasedCount: purchasedCount, tid: purchaseTid, pid: purchasePid);
    }

    // Check for locked with sale.
    final salesTid = element.querySelector('em > a')?.attributes['href']?.tryParseAsUri()?.queryParameters['tid'];
    // Only for current user on selling side.
    final salesCount = element
        .querySelector('span.pipe')
        ?.nextElementSibling
        ?.firstEndDeepText()
        ?.split(' ')
        .lastOrNull
        ?.parseToInt();
    if (price != null && salesTid != null && salesCount != null) {
      if (!allowWithSale) {
        return null;
      }

      return _LockedInfo.sale(price: price, salesCount: salesCount, tid: salesTid);
    }

    if (allowWithBlocked && element.innerText.contains('该帖被管理员或版主屏蔽')) {
      return const _LockedInfo.banned();
    }

    if (!allowWithPoints) {
      // Do not allow locked area that locked with points here.
      return null;
    }

    /// Points type;
    final re = RegExp(r'高于 (?<requiredPoints>\d+) 才可浏览(，您当前积分为 (?<points>\d+))?');
    final match = re.firstMatch(element.innerText);
    final requiredPoints = match?.namedGroup('requiredPoints')?.parseToInt();
    final points = match?.namedGroup('points')?.parseToInt();
    if (requiredPoints == null) {
      return null;
    }
    return _LockedInfo.points(requiredPoints: requiredPoints, points: points);
  }

  /// Check is valid locked area or not.
  bool isValid() {
    if (_info == null) {
      return false;
    }
    if (_info is _LockedWithReply) {
      return true;
    }

    if (_info is _LockedWithPurchase) {
      return _info.price > 0 && tid != null && pid != null;
    }
    if (_info is _LockedWithSale) {
      return _info.price > 0 && tid != null;
    }
    if (_info is _LockedWithPoints || _info is _LockedWithAuthor || _info is _LockedWithBlocked) {
      return true;
    }
    return false;
  }

  /// Check is invalid locked area or not.
  bool isNotValid() => !isValid();

  @override
  List<Object?> get props => [_info];
}
