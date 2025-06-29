import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/features/theme/cubit/theme_cubit.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:tsdm_client/widgets/card/packet_card.dart';
import 'package:tsdm_client/widgets/card/rate_card.dart';
import 'package:universal_html/parsing.dart';

/// Showcase page for debugging.
class DebugShowcasePage extends StatefulWidget {
  /// Constructor.
  const DebugShowcasePage({super.key});

  @override
  State<DebugShowcasePage> createState() => _DebugShowcasePageState();
}

class _DebugShowcasePageState extends State<DebugShowcasePage> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SHOWCASE'),
        bottom: TabBar(
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          controller: tabController,
          tabs: const [Tab(text: 'HTML')],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode_outlined),
            selectedIcon: const Icon(Icons.dark_mode),
            isSelected: Theme.of(context).brightness == Brightness.dark,
            onPressed: () {
              switch (Theme.of(context).brightness) {
                case Brightness.dark:
                  context.read<ThemeCubit>().setThemeModeIndex(1);
                case Brightness.light:
                  context.read<ThemeCubit>().setThemeModeIndex(2);
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: const [SingleChildScrollView(child: _HtmlFragment())],
      ),
    );
  }
}

class _HtmlFragment extends StatelessWidget {
  const _HtmlFragment();

  static const rateBlockData = '''
<dl id="ratelog_POST_ID" class="rate">
  <dd style="margin:0">
    <div id="post_rate_POST_ID"></div>
    <table class="ratl">
      <tbody>
        <tr>
        <th class="xw1"><a href="">已有 <span class="xi1">10</span> 人评分</a></th>
        <th><i>威望</i></th>
        <th><i>天使币</i></th>
        <th><i>天然</i></th>
        <th><i>腹黑</i></th>
        <th>
        <i>理由</i>
        </th>
        </tr>
      </tbody>
      <tbody class="ratl_l">
        <tr id="rate_SOME_ID">
          <td>
            <a href=""><img src="uc_server/images/noavatar_middle.gif"/></a>
            <a href="home.php?mod=space&amp;uid=0">USER 0</a>
          </td>
          <td class="xg1"></td>
          <td class="xg1"></td>
          <td class="xi1"> + 200</td>
          <td class="xi1"> + 200</td>
          <td class="xg1">REASON 1</td>
        </tr>
        <tr id="rate_SOME_ID">
          <td>
            <a href=""><img src="uc_server/images/noavatar_middle.gif"></a>
            <a href="home.php?mod=space&amp;uid=0">USER 1</a>
          </td>
          <td class="xg1"></td>
          <td class="xg1"> + 100</td>
          <td class="xi1"> + 100</td>
          <td class="xi1"></td>
          <td class="xg1">REASON 1</td>
        </tr>
        <tr id="rate_SOME_ID">
          <td>
            <a href=""><img src="uc_server/images/noavatar_middle.gif"></a>
            <a href="home.php?mod=space&amp;uid=0" target="_blank">USER 2</a>
          </td>
          <td class="xg1"></td>
          <td class="xg1"></td>
          <td class="xi1"> + 1</td>
          <td class="xi1"> + 1</td>
          <td class="xg1"></td>
        </tr>
      </tbody>
    </table>
    <p class="ratc">
    总评分:&nbsp;<span class="xi1">威望 + 12321</span>&nbsp;
    <span class="xi1">天使币 + 1234</span>&nbsp;
    <span class="xi1">天然 + 56789</span>&nbsp;
    <span class="xi1">腹黑 + 56789</span>&nbsp;
    &nbsp;<a href="" class="xi2">查看全部评分</a>
    </p>
  </dd>
</dl>
''';

  static const htmlData = '''
<body>
  <h1>TITLE 1</h1>
  <h2>TITLE 2</h2>
  <h3>TITLE 3</h3>
  
  <!-- Expand/Collapse -->
  <div class="spoiler">
    <div class="spoiler_control">
      <input class="spoiler_btn" type="button" value="Detail Card"/>
    </div>
    <div class="spoiler_content">
      <div class="showhide">
        detail 1detaildetaildetaildetaildetaildetaildetaildetaildetail
        <br/>
        detail 2
      </div>
    </div>
  </div>
  
  <!-- Locked with purchase -->
  <div class="locked">
    <a class="y viewpay" title="title: purchase to see this content" 
    onclick="showWindow('pay', 'forum.php?mod=misc&action=pay&tid=0&pid=0')">
    SOMETHING HERE
    </a>
    <em class="right">已有 12347890 人购买</em>
    <strong>4 coins</strong>
  </div>
  
  <!-- Locked with author -->
  <div class="locked">此帖仅作者可见</div>
  
  <!-- Locked with points -->
  <div class="locked">
  USERNAME本帖隐藏的内容需要积分高于 1234567 才可浏览，您当前积分为 1234
  </div>
  
  <!-- Locked with reply -->
  <div class="locked">
  USERNAME，如果您要查看本帖隐藏内容请<a href="forum.php?mod=post&amp;action=reply&amp;fid=0&amp;tid=0" onclick="showWindow('reply', this.href)">回复</a>
  </div>
  
  <!-- Code block -->
  <div class="blockcode">
    <div id="code_SOME_HASH">
      <ol><li>code line 1
</li><li>code line 2</li>
      </ol>
    </div>
  </div>
  
  <!-- Music iframe player -->
  <iframe src="//music.163.com/outchain/player?id=1962823032"></iframe>
</body>
''';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        munchElement(context, parseHtmlDocument(htmlData).body!, parseLockedWithPurchase: true),
        RateCard(Rate.fromRateLogNode(parseHtmlDocument(rateBlockData).body)!, '100000'),
        const PacketCard('', allTaken: false),
        const PacketCard('', allTaken: true),
      ],
    );
  }
}
