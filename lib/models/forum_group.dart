import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/models/forum.dart';
import 'package:universal_html/html.dart' as uh;

class _ForumGroupInfo {
  _ForumGroupInfo({
    required this.name,
    required this.url,
    required this.forumList,
  });

  String name;
  String url;
  List<Forum> forumList;
}

class ForumGroup {
  ForumGroup.fromBMNode(uh.Element element) : _info = _buildFromBMNode(element);

  final _ForumGroupInfo _info;

  String get name => _info.name;

  String get url => _info.url;

  List<Forum> get forumList => _info.forumList;

  /// Build from <div class="bm bmw flg cl"> or <div class="forumbox"> [element]
  static _ForumGroupInfo _buildFromBMNode(uh.Element element) {
    final titleNode = element.querySelector('div:nth-child(1) > h2') ??
        // Style 5
        element.querySelector('div.title_r > h2 > a');
    final name = titleNode?.firstEndDeepText();
    final url = titleNode?.attributes['href'];

    final subForumNodeList = element
        .querySelectorAll('div:nth-child(2) > table > tbody > tr')
        .toList();

    final forumList = <Forum>[];
    for (final subForumNode in subForumNodeList) {
      // If children is empty, these are invisible elements in web page, skip.
      if (subForumNode.children.isEmpty) {
        continue;
      }

      // Here we can not tell whether the sub forums are in expanded layout or
      // not by checking element attributes.
      // The only way to check this is looking at the image node in sub forums.

      // Expanded layout forum layout.
      if (subForumNode.querySelector('td > a') != null) {
        final forum = Forum.fromFlRowNode(subForumNode);
        forumList.add(forum);
        continue;
      }

      // Normal layout forum has attribute class=fl_g
      final forumFlGNodeList =
          subForumNode.querySelectorAll('td.fl_g').toList();
      if (forumFlGNodeList.isEmpty) {
        continue;
      }
      forumList.addAll(forumFlGNodeList.map(Forum.fromFlGNode));
    }

    return _ForumGroupInfo(
      name: name ?? '',
      url: url ?? '',
      forumList: forumList,
    );
  }
}
