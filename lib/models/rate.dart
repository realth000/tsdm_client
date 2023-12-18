import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/models/user.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

/// Rate record for a single user.
class SingleRate {
  SingleRate({
    required this.user,
    required this.attrValueList,
  });

  /// User info.
  /// Name, user space url and avatar url is required.
  final User user;

  /// Rate content.
  /// Values for each attr in this rate.
  /// Should have same length with attrList in rate info table.
  final List<String> attrValueList;
}

class _RateInfo {
  _RateInfo({
    required this.userCount,
    required this.detailUrl,
    required this.attrList,
    required this.records,
    required this.rateStatus,
  });

  _RateInfo.empty()
      : userCount = null,
        detailUrl = null,
        attrList = [],
        records = [],
        rateStatus = null;

  /// Count of users rated.
  final int? userCount;

  /// Url contains rate detail info.
  final String? detailUrl;

  /// Rated attributes.
  /// Show as column header.
  /// Should have same length with attrValueList in single rate record.
  final List<String> attrList;

  /// Records of rating.
  final List<SingleRate> records;

  /// Total rate status.
  final String? rateStatus;
}

/// Rate record for a single post.
///
/// Contains a series of [SingleRate]s, including rated attributes and their
/// values. Users who rated also recorded.
class Rate {
  /// Build a [Rate] from element <dl id="ratelog_xxx" class="rate">.
  Rate.fromRateLogNode(uh.Element element)
      : _info = _buildRateInfoFromNode(element);

  final _RateInfo _info;

  int? get userCount => _info.userCount;

  String? get detailUrl => _info.detailUrl;

  List<String> get attrList => _info.attrList;

  List<SingleRate> get records => _info.records;

  String? get rateStatus => _info.rateStatus;

  static _RateInfo _buildRateInfoFromNode(uh.Element element) {
    final rateHeaders =
        element.querySelectorAll('table > tbody:nth-child(1) > tr > th');
    if (rateHeaders.length < 2) {
      return _RateInfo.empty();
    }

    final infoNode = rateHeaders.firstOrNull?.querySelector('a');
    final userCount =
        infoNode?.querySelector('span.xi1')?.firstEndDeepText()?.parseToInt();
    final detailUrl = infoNode?.firstHref();
    final attrList = rateHeaders
        .skip(1)
        .map((e) => e.querySelector('i')?.firstEndDeepText()?.trim())
        .whereType<String>()
        .toList();

    final recordNodeList =
        element.querySelectorAll('table > tbody.ratl_l > tr');
    final records =
        recordNodeList.map(_parseSingleRate).whereType<SingleRate>().toList();
    final rateStatus = element
        .querySelector('p.ratc')
        ?.querySelectorAll('span')
        .map((e) => e.firstEndDeepText())
        .whereType<String>()
        .toList()
        .join(' ');

    return _RateInfo(
      userCount: userCount,
      detailUrl: detailUrl,
      attrList: attrList,
      records: records,
      rateStatus: rateStatus,
    );
  }

  /// Try parse a [SingleRate] from [element] <tr id="xxx">
  static SingleRate? _parseSingleRate(uh.Element element) {
    final tdList = element.querySelectorAll('td');
    if (tdList.length < 2) {
      return null;
    }
    final userNode = tdList.firstOrNull;
    final url = userNode?.querySelector('a:nth-child(1)')?.firstHref();
    final avatarUrl =
        userNode?.querySelector('a:nth-child(1) > img')?.imageUrl();
    final name = userNode?.querySelector('a:nth-child(2)')?.firstEndDeepText();
    final attrValueList =
        tdList.skip(1).map((e) => e.firstEndDeepText()?.trim() ?? '').toList();

    if (url == null || name == null) {
      return null;
    }
    return SingleRate(
      user: User(
        name: name,
        url: url,
        avatarUrl: avatarUrl,
      ),
      attrValueList: attrValueList,
    );
  }

  bool isValid() {
    if (userCount == null ||
        detailUrl == null ||
        attrList.isEmpty ||
        records.isEmpty ||
        rateStatus == null) {
      debug(
          'invalid rate $userCount, $detailUrl, $attrList, $records, $rateStatus');
      return false;
    }

    return true;
  }
}
