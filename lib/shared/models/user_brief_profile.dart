import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

part '../../generated/shared/models/user_brief_profile.mapper.dart';

/// A brief user profile shows along with user's post in thread page.
@MappableClass()
final class UserBriefProfile with UserBriefProfileMappable {
  /// Constructor.
  const UserBriefProfile({
    required this.username,
    required this.avatarUrl,
    required this.uid,
    required this.nickname,
    required this.userGroup,
    required this.title,
    required this.recommended,
    required this.threadCount,
    required this.postCount,
    required this.famous,
    required this.coins,
    required this.publicity,
    required this.natural,
    required this.scheming,
    required this.spirit,
    required this.seal,
    required this.couple,
    required this.privilege,
    required this.registrationDate,
    required this.comeFrom,
    required this.online,
  });

  /// Username.
  ///
  /// 用户名
  final String username;

  /// User avatar url.
  ///
  /// Actually should not be empty but we notice it.
  final String? avatarUrl;

  /// User id.
  ///
  /// UID
  final String uid;

  /// Custom nickname.
  ///
  /// 自定义头衔
  final String? nickname;

  /// Name of user group.
  ///
  /// 用户组
  final String userGroup;

  /// Custom user title.
  ///
  /// 称号
  final String? title;

  /// Recommended thread count.
  ///
  /// 精华
  final String recommended;

  /// Thread posted count.
  ///
  /// 主题
  final String threadCount;

  /// Posts posted count.
  ///
  /// 帖子
  final String postCount;

  /// User attr score3.
  ///
  /// 威望
  final String famous;

  /// Coins count.
  ///
  /// 天使币
  final String coins;

  /// User attr.
  ///
  /// 宣传
  final String publicity;

  /// User attr score4
  ///
  /// 天然
  final String natural;

  /// User attr score5
  ///
  /// 腹黑
  final String scheming;

  /// User attr score
  ///
  /// 精灵
  final String spirit;

  /// User attr
  ///
  /// 龙之印章
  final String seal;

  // TODO: Reserve as link.
  /// Couple username.
  ///
  /// CP
  final String? couple;

  /// User privilege value.
  ///
  /// 阅读权限
  final String privilege;

  /// Date of account registration.
  ///
  /// 注册时间
  final String registrationDate;

  /// Place come from
  ///
  /// 来自
  final String? comeFrom;

  /// Now online or not.
  ///
  /// 状态
  final bool online;

  /// Build a [UserBriefProfile] instance from user node [element].
  ///
  /// User node must be:
  ///
  /// ```html
  /// <td id="userinfo_${UID}", ...> ... </td>
  /// ```
  static UserBriefProfile? buildFromUserProfileNode(uh.Element element) {
    final uid = element.id.split('_').lastOrNull;
    if (uid == null) {
      debug('failed to build UserBriefProfile: uid not found');
      return null;
    }
    final avatarNode = element.querySelector('div#ts_avatar_$uid');
    if (avatarNode == null) {
      debug('failed to build UserBriefProfile: avatar node not found');
      return null;
    }
    final username = avatarNode.querySelector('div:nth-child(1)')?.innerText;
    // Allow empty value.
    final nickname = avatarNode.querySelector('div:nth-child(2)')?.innerText;
    final avatarUrl =
        avatarNode.querySelector('div.avatar > a > img')?.imageUrl();
    if (username == null || nickname == null || avatarUrl == null) {
      debug(
        'warning when build UserBriefProfile: username or nickname or'
        ' avatarUrl not found',
      );
    }

    final statBarNode = element.querySelector('div.tsdm_statbar');
    if (statBarNode == null) {
      debug('failed to build UserBriefProfile: statBarNode not found');
      return null;
    }
    final userGroup = statBarNode.children.firstOrNull?.innerText;

    String? title;
    String? recommended;
    String? threadCount;
    String? postCount;
    String? famous;
    String? coins;
    String? publicity;
    String? natural;
    String? scheming;
    String? spirit;
    String? seal;
    String? couple;
    String? privilege;
    String? registrationDate;
    String? comeFrom;

    bool? online;

    for (final pair in statBarNode.querySelectorAll('> span').slices(2)) {
      if (pair.length < 2) {
        continue;
      }
      final data = pair[1].innerText;
      final _ = switch (pair[0].innerText) {
        '头衔:' => title = data,
        '精华:' => recommended = data,
        '主题:' => threadCount = data,
        '帖子:' => postCount = data,
        '威望:' => famous = data,
        '天使币:' => coins = data,
        '宣传度:' => publicity = data,
        '天然°:' => natural = data,
        '腹黑°:' => scheming = data,
        '精灵:' => spirit = data,
        '龙之印章:' => seal = data,
        'CP:' => couple = data,
        '阅读权限:' => privilege = data,
        '注册时间:' => registrationDate = data,
        '来自:' => comeFrom = data,
        _ => '',
      };
    }

    online = statBarNode.querySelector('> a')?.title?.contains('在线') ?? false;

    return UserBriefProfile(
      username: username ?? '',
      avatarUrl: avatarUrl,
      uid: uid,
      nickname: nickname,
      userGroup: userGroup ?? '',
      title: title,
      recommended: recommended ?? '',
      threadCount: threadCount ?? '',
      postCount: postCount ?? '',
      famous: famous ?? '',
      coins: coins ?? '',
      publicity: publicity ?? '',
      natural: natural ?? '',
      scheming: scheming ?? '',
      spirit: spirit ?? '',
      seal: seal ?? '',
      couple: couple ?? '',
      privilege: privilege ?? '',
      registrationDate: registrationDate ?? '',
      comeFrom: comeFrom,
      online: online,
    );
  }
}
