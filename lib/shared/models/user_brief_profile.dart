part of 'models.dart';

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
    required this.specialAttr,
    required this.specialAttrName,
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

  /// Special attr that changes over time.
  ///
  /// 龙之印章/西瓜
  final String specialAttr;

  /// Name of [specialAttr].
  final String specialAttrName;

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
    final postId = element.id.split('_').lastOrNull;
    if (postId == null) {
      talker.error('failed to build UserBriefProfile: uid not found');
      return null;
    }
    final avatarNode = element.querySelector('div#ts_avatar_$postId');
    if (avatarNode == null) {
      talker.error('failed to build UserBriefProfile: avatar node not found');
      return null;
    }
    final username = avatarNode.querySelector('div:nth-child(1)')?.innerText;
    // Allow empty value.
    final nickname = avatarNode.querySelector('div:nth-child(2)')?.innerText;
    final avatarUrl =
        avatarNode.querySelector('div.avatar > a > img')?.imageUrl();
    if (username == null || nickname == null || avatarUrl == null) {
      talker.error(
        'warning when build UserBriefProfile: username or nickname or'
        ' avatarUrl not found',
      );
    }

    final statBarNode = element.querySelector('div.tsdm_statbar');
    if (statBarNode == null) {
      talker.error('failed to build UserBriefProfile: statBarNode not found');
      return null;
    }
    final userGroup = statBarNode.children.firstOrNull?.innerText.trim();

    String? uid;
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
    String? specialAttr;
    // Name of special attr.
    String? specialAttrName;
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
        'UID:' => uid = data,
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
        'CP:' => couple = data,
        '阅读权限:' => privilege = data,
        '注册时间:' => registrationDate = data,
        '来自:' => comeFrom = data,
        // Special attr that changes over time.
        // 2023 春节
        '龙之印章:' => () {
            specialAttr = data;
            specialAttrName = '龙之印章';
          }(),
        // 2024 夏日
        '西瓜:' => () {
            specialAttr = data;
            specialAttrName = '西瓜';
          }(),
        // 2024 坛庆
        '爱心❤:' => () {
            specialAttr = data;
            specialAttrName = '爱心';
          }(),
        _ => '',
      };
    }

    online =
        statBarNode.querySelector('div > a')?.title?.contains('在线') ?? false;

    return UserBriefProfile(
      username: username ?? '',
      avatarUrl: avatarUrl,
      uid: uid ?? '',
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
      specialAttr: specialAttr ?? '',
      specialAttrName: specialAttrName ?? '',
      couple: couple ?? '',
      privilege: privilege ?? '',
      registrationDate: registrationDate ?? '',
      comeFrom: comeFrom,
      online: online,
    );
  }
}
