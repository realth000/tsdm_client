import 'package:flutter_test/flutter_test.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:universal_html/parsing.dart';

/// Common user data to pass post data building.
const _postBodyAuthorData = '''
<td id="userinfo_123789" class="pls" rowspan="2">
  <!--userinfo block start. stay blank TD-->
 <div class="p_pop blk bui" id="userinfo123789" style="display: none; ">
<div class="m z">
<div class="userinfo_float_side">
<div id="userinfo123789_ma" class="userinfo_float_side_ma"></div>
</div>
</div>
<div class="i y">
<div>
<strong><a href="https://www.tsdm39.com/home.php?mod=space&amp;uid=123789" target="_blank" class="xi2">test_user</a></strong>
<em>当前离线</em>
</div>
<dl class="cl"><dt>UID</dt><dd>123789</dd><dt>帖子</dt><dd><a href="https://www.tsdm39.com/home.php?mod=space&amp;uid=123789&amp;do=thread&amp;type=reply&amp;view=me&amp;from=space" target="_blank" class="xi2">2100</a></dd></dl>
<div class="imicn">
<li class="buddy"><a href="https://www.tsdm39.com/home.php?mod=spacecp&amp;ac=friend&amp;op=add&amp;uid=123789&amp;handlekey=addfriendhk_123789" id="a_friend_li_123789" onclick="showWindow(this.id, this.href, 'get', 1, {'ctrlid':this.id,'pos':'00'});" title="加好友" class="xi2">加好友</a></li>
<li class="pm2"><a href="https://www.tsdm39.com/home.php?mod=spacecp&amp;ac=pm&amp;op=showmsg&amp;handlekey=showmsg_123789&amp;touid=123789&amp;pmid=0&amp;daterange=2&amp;pid=70986025&amp;tid=1179745" onclick="showWindow('sendpm', this.href);" title="发消息" class="xi2">发消息</a></li>
<a href="https://www.tsdm39.com/home.php?mod=space&amp;uid=123789&amp;do=profile" target="_blank" title="查看详细资料"><img src="static/image/common/userinfo.gif" alt="查看详细资料"></a>

<a href="https://www.tsdm39.com/home.php?mod=magic&amp;mid=checkonline&amp;idtype=user&amp;id=t222" id="a_repent_70986025" class="xi2" onclick="showWindow(this.id, this.href)"><img src="static//image/magic/checkonline.small.gif" alt=""> 狗仔卡</a>
<div class="somehead"></div>
</div>
<div id="avatarfeed"><span id="threadsortswait"></span></div>
</div>
</div>
<div id="ts_avatar_123456">
<div class="post_username_3">test_user</div>
<div class="post_nickname"></div>
<div class="avatar" onmouseover="showauthor(this, 'userinfo123789')"><a class="userinfo_float_a" href="https://www.tsdm39.com/home.php?mod=space&amp;uid=123789" target="_blank"><img class="lazy" src="https://www.user_avatar/src" data-original="https://www.user_avatar/data-original" onerror="this.onerror=null;this.src='https://www.user_avatar/src'" style="display: inline;"></a></div>
</div>
<p></p>
</td>
''';

/// Common post body that have both <div class="pcb"> and <table> node.
///
/// tid: 1188184
const _postBodyWithPcbTable = '''
<div id="post_123456">
  <table id="pid123456">
    <tbody>
      <tr>
        $_postBodyAuthorData
        <td>
          <div id="pct">
            <div class="pcb">
              <div class="t_fsz">
                <table>
                  <tbody>
                    <tr>
                      <td id="postmessage_123456">
                        <br>
                        test_body_with_pcb_table
                        <br>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</div>
''';

/// Post body with <div class="pcb"> but none <table> node.
///
/// tid: 1189593
const _postBodyWithPcb = '''
<div id="post_123456">
  <table id="pid123456">
    <tbody>
      <tr>
        $_postBodyAuthorData
        <td>
          <div id="pct">
            <div class="pcb">
              <div class="t_fsz">
              <br>
              test_body_with_pcb
              <br>
              </div>
            </div>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</div>
''';

/// Post data with <div class="pcbs"> appears in post with poll form.
///
/// tid: 1189614
const _postBodyWithPcbs = '''
<div id="post_123456">
  <table id="pid123456">
    <tbody>
      <tr>
        $_postBodyAuthorData
        <td>
          <div id="pct">
            <div class="pcb">
              <div class="pcbs">
                <table>
                  <tbody>
                    <tr>
                      <td id="postmessage_123456">
                        <br>
                        test_body_with_pcbs
                        <br>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</div>
''';

/// Post body with purchase area.
///
/// tid: 1179745
const _postBodyWithLockedWithPurchase = '''
<div id="post_123456">
  <table id="pid123456">
    <tbody>
      <tr>
        $_postBodyAuthorData
        <td>
          <div id="pct">
            <div class="pcb">
              <div id="postmessage_123456">
                <br>
                test_body_with_locked_with_purchase
                <br>
              </div>
              <div class="locked">
                <a href="javascript:;" class="y viewpay" title="购买主题(Buy the article / 文章を購入する)" onclick="showWindow('pay', 'forum.php?mod=misc&amp;action=pay&amp;tid=1179745&amp;pid=70986025')">购买主题(Buy the article / 文章を購入する)</a>
                <em class="right">已有 138 人购买</em>
                本主题需向作者支付 <strong>12 天使币</strong> 才能浏览<p><a href="https://www.tsdm39.com/forum.php?mod=viewthread&amp;tid=447920" target="_blank">简单升级</font></strong></a></p>
              </div>
            </div>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</div>
''';

void main() {
  group('ParsePostBody', () {
    test('with pcb and table', () {
      final document = parseHtmlDocument(_postBodyWithPcbTable);
      final postData = Post.fromPostNode(
        document.body!.querySelector('div')!,
        1,
      );
      expect(postData?.data.contains('test_body_with_pcb_table'), true);
      expect(postData?.author.uid, '123789');
      expect(postData?.author.name, 'test_user');
      expect(
        postData?.author.avatarUrl,
        'https://www.user_avatar/data-original',
      );
    });
    test('with pcb', () {
      final document = parseHtmlDocument(_postBodyWithPcb);
      final postData = Post.fromPostNode(
        document.body!.querySelector('div')!,
        1,
      );
      expect(postData?.data.contains('test_body_with_pcb'), true);
      expect(postData?.author.uid, '123789');
      expect(postData?.author.name, 'test_user');
      expect(
        postData?.author.avatarUrl,
        'https://www.user_avatar/data-original',
      );
    });
    test('with pcbs', () {
      final document = parseHtmlDocument(_postBodyWithPcbs);
      final postData = Post.fromPostNode(
        document.body!.querySelector('div')!,
        1,
      );
      expect(postData?.data.contains('test_body_with_pcbs'), true);
      expect(postData?.author.uid, '123789');
      expect(postData?.author.name, 'test_user');
      expect(
        postData?.author.avatarUrl,
        'https://www.user_avatar/data-original',
      );
    });
    test('with locked with purchase', () {
      final document = parseHtmlDocument(_postBodyWithLockedWithPurchase);
      final postData = Post.fromPostNode(
        document.body!.querySelector('div')!,
        1,
      );
      expect(
        postData?.data.contains('test_body_with_locked_with_purchase'),
        true,
      );
      expect(postData?.author.uid, '123789');
      expect(postData?.author.name, 'test_user');
      expect(
        postData?.author.avatarUrl,
        'https://www.user_avatar/data-original',
      );
      expect(postData?.locked.length, 1);
      expect(postData!.locked[0].lockedWithPurchase, true);
      expect(postData.locked[0].purchasedCount, 138);
      expect(postData.locked[0].tid, '1179745');
      expect(postData.locked[0].pid, '70986025');
    });
  });
}
