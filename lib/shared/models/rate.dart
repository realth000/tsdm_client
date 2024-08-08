part of 'models.dart';

/// Single rate record for a single user.
@MappableClass()
class SingleRate with SingleRateMappable {
  /// Constructor.
  const SingleRate({
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

/// Rate record for a single user.
@MappableClass()
class Rate with RateMappable {
  /// Constructor.
  const Rate({
    required this.userCount,
    required this.detailUrl,
    required this.attrList,
    required this.records,
    required this.rateStatus,
  });

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

  /// Build a [Rate] from element <dl id="ratelog_xxx" class="rate">.
  static Rate? fromRateLogNode(uh.Element? element) {
    if (element == null) {
      return null;
    }
    final rateHeaders =
        element.querySelectorAll('table > tbody:nth-child(1) > tr > th');
    if (rateHeaders.length < 2) {
      talker.error('failed to build rate: invalid rate header');
      return null;
    }

    final infoNode = rateHeaders.firstOrNull?.querySelector('a');
    final userCount =
        infoNode?.querySelector('span.xi1')?.firstEndDeepText()?.parseToInt();
    if (userCount == null) {
      talker.error('failed to build rate: user count not found');
      return null;
    }
    final detailUrl = infoNode?.firstHref();
    if (detailUrl == null) {
      talker.error('failed to build rate: detail url not found');
      return null;
    }
    final attrList = rateHeaders
        .skip(1)
        .map((e) => e.querySelector('i')?.firstEndDeepText()?.trim())
        .whereType<String>()
        .toList();
    if (attrList.isEmpty) {
      talker.error('failed to build rate: rate attr list is empty');
      return null;
    }

    final recordNodeList =
        element.querySelectorAll('table > tbody.ratl_l > tr');
    final records =
        recordNodeList.map(_parseSingleRate).whereType<SingleRate>().toList();
    if (records.isEmpty) {
      talker.error('failed to build rate: records is empty');
      return null;
    }

    final rateStatus = element
        .querySelector('p.ratc')
        ?.querySelectorAll('span')
        .map((e) => e.firstEndDeepText())
        .whereType<String>()
        .toList()
        .join(' ');
    if (rateStatus == null) {
      talker.error('failed to build rate: rate status not found');
      return null;
    }

    return Rate(
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
}
