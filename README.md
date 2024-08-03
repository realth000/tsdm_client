<h1 align="center">
    <a href="https://github.com/realth000/tsdm_client/">
        <img src="./assets/images/tsdm_client.svg" width="120px">
    </a>
    <br>
    tsdm_client
</h1>

<p align="center">
使用Flutter制作的天使动漫（tsdm39.com）论坛非官方客户端
</p>

<p align="center">
  <a href="https://github.com/realth000/tsdm_client/actions"><img src="https://img.shields.io/github/actions/workflow/status/realth000/tsdm_client/test.yml?label=test"/></a>
  <a href="https://github.com/realth000/tsdm_client/releases"><img src="https://img.shields.io/github/release/realth000/tsdm_client?label=version"></a>
  <a href="https://github.com/realth000/tsdm_client/releases"><img src="https://img.shields.io/badge/platform-Android_%7C_iOS_%7C_Linux_%7C_MacOS_%7C_Windows-19A6E6"></a>
  <a href="https://github.com/realth000/tsdm_client/releases"><img src="https://img.shields.io/github/downloads/realth000/tsdm_client/total"></a>
  <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-3.22-19A6E6?logo=flutter"></a>
  <a href="https://dart.dev/"><img src="https://img.shields.io/github/languages/top/realth000/tsdm_client?logo=dart"/></a>
  <a href="https://app.codacy.com/gh/realth000/tsdm_client/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade"><img src="https://app.codacy.com/project/badge/Grade/28ffb16db1ba4d8a943d9feba3a402b3"></a>
  <a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg"></a>
</p>

> [!TIP]
>
> 受测试条件限制，标注为已实现的功能也可能有缺陷，欢迎提issue或PR。

## 截图

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img width="100%" src="./doc/pic/screenshot_01.png">
      </td>
      <td align="center">
        <img width="100%" src="./doc/pic/screenshot_02.png">
      </td>
    </tr>
    <tr>
      <td align="center">
        <img width="100%" src="./doc/pic/screenshot_03.png">
      </td>
      <td align="center">
        <img width="100%" src="./doc/pic/screenshot_04.png">
      </td>
    </tr>
  </table>
</div>

## 下载

* [GitHub Release](https://github.com/realth000/tsdm_client/releases)
  * [Android apk (armv8)](https://github.com/realth000/tsdm_client/releases/latest/download/tsdm_client-arm64_v8a.apk)
  * [Android apk (armv7)](https://github.com/realth000/tsdm_client/releases/latest/download/tsdm_client-armeabi_v7a.apk)
  * [iOS ipa](https://github.com/realth000/tsdm_client/releases/latest/download/tsdm_client.ipa)
  * [Linux tar.gz](https://github.com/realth000/tsdm_client/releases/latest/download/tsdm_client-linux.tar.gz)
  * [MacOS dmg](https://github.com/realth000/tsdm_client/releases/latest/download/tsdm_client-universal.dmg)
  * [Windows](https://github.com/realth000/tsdm_client/releases/latest/download/tsdm_client-windows.zip)

## 功能

*斜体字的功能已在master分支实现但尚未发布到release*

* [ ] 看贴
  * [x] 回复
  * [x] 基本信息（用户名、头像）
  * [x] 其他信息（分组、勋章、昵称、头衔等）
  * [x] 链接跳转
  * [x] 电梯直达
  * [x] 倒序浏览
  * [x] 筛选和排序帖子
  * [x] 只看指定作者
  * [x] 展开/折叠
  * [x] 引用
  * [ ] 投票
  * [x] 查看点评
  * [x] 评分/查看评分
  * [x] 代码块
  * [ ] 复制内容
  * [x] 我的帖子
  * [x] 查看新帖
  * [x] 帖子类型（加精，置顶，已关闭等）
  * [x] 置顶帖
  * [x] 领取红包
  * [x] 悬赏/悬赏答案
  * [x] 用户积分信息
  * [ ] 签名档
  * [x] 查看图片
* [x] 回帖
  * [x] 回复文字
  * [x] 回复其他楼层
  * [x] 编辑回复
  * [x] 编辑帖子（一楼）
  * [x] [富文本模式](#富文本支持)
* [ ] 编辑帖子
  * [x] 修改纯文本内容
  * [x] 设置分类和标题
  * [x] 设置附加选项
  * [ ] 设置阅读权限
  * [ ] 设置售价
  * [x] [富文本模式](#富文本支持)
* [ ] 发帖
  * [ ] 纯文本内容
  * [ ] 保存为草稿
  * [ ] 编辑草稿
  * [ ] 本地自动保存
  * [ ] 设置分类和标题
  * [ ] 设置附加选项
  * [ ] 设置阅读权限
  * [ ] 设置售价
  * [ ] [富文本模式](#富文本支持)
* [ ] 登录
  * [x] 用户名登录
  * [ ] UID或邮箱登录
  * [x] 带安全问题登录
  * [x] 登录一次后cookie自动登录
  * [x] 退出登录
* [x] 搜索
  * [x] 按作者id和论坛id搜索
* [x] 积分
  * [x] 积分统计和历史记录
  * [x] 查询积分记录
* [ ] 购买
  * [x] 购买帖子
  * [x] 回复后可见
  * [ ] 购买记录
* [ ] 签到
  * [x] 手动签到
  * [ ] 自动签到
* [ ] 深色模式
  * [x] 手动设置
  * [x] 跟随系统
  * [ ] 自动调整字体颜色
* [ ] 主题
  * [x] 更换主题色
  * [ ] 动态颜色（Android）
* [ ] 用户信息
  * [x] 查看用户信息
  * [x] 积分信息
  * [x] 签名档
  * [ ] 修改头像
  * [ ] 修改个人资料
* [ ] 通知
  * [x] 查看提醒 - 回复 评分 提及 邀请参与话题 已添加好友 批量评分
  * [ ] 查看提醒 - 好友申请 转账
  * [x] 回复提醒
  * [x] 跳转到提醒的帖子
  * [x] 查看私信/系统消息
  * [x] 查看私信对话历史
  * [x] 回复私信
  * [x] 发送私信
  * [x] 发送富文本私信
  * [ ] 转账
* [ ] 好友
  * [ ] 加好友
  * [ ] 查看好友
  * [ ] 分组
  * [ ] 删除
* [x] 应用内更新
* [ ] 收藏
  * [ ] 收藏帖子或分区
* [ ] 多用户
* [ ] 多语言
  * [x] 软件界面
  * [ ] 浏览内容翻译为繁体中文
* [ ] ...

## 富文本支持

### 概述

目前正在添加bbcode的富文本支持，最终会在发表帖子/回复/消息等场景内支持所见即所得的bbcode书写体验。

然而这部分内容很多，无法在短期内实现 ~~（实际上已经导致发版延期很久了）~~。

故采用逐步添加功能的方式逐渐改进。

在富文本功能稳定之前，同时保留现有的普通编辑器和（实验性的）富文本编辑器。

BBCode编辑器主要功能存放在单独的仓库[flutter_bbcode_editor](https://github.com/realth000/flutter_bbcode_editor)中。

### 进度

**[BBCode编辑器](https://github.com/realth000/flutter_bbcode_editor)仍处于试验阶段**

* [x] 文本样式
  * [ ] 字号（固定大小1-7）
    * [x] 选择文字后设置
    * [ ] 设置后对光标处生效
  * [x] 字体颜色
  * [x] 背景颜色
  * [x] 粗体
  * [x] 斜体
  * [x] 下划线
  * [x] 删除线
  * ~~字体~~（不实现）
* [ ] 表情
  * [x] 添加
  * [ ] 设置表情分组顺序
* [ ] 网页链接
  * [x] 添加
  * [ ] 修改
* [ ] 外链图片
  * [x] 添加
  * [x] 设置大小
  * [ ] 修改
* [ ] 折叠卡片
* [ ] 隐藏内容
* [ ] 代码块
* [ ] 引用文字
* [ ] 对齐
* [ ] 分隔线
* [x] 提醒用户（@）
* [ ] 无序列表
* [ ] 有序列表
* [ ] 表格
* [ ] 上标
* [x] 对齐（居左/居中/居右）

## 已知问题

~~在修了在修了~~

* 暂不支持论坛的`璀璨星河`主题，请不要在设置中使用该主题。
* 受限于解析和排布html节点的方式，少部分包含复杂回复楼层的帖子打开会**严重卡顿**。
* 长时间使用至cookie过期时一些功能可能无法使用，例如签到，此时请重新登录。

## 支持平台

* [x] Android
* [x] iOS
* [x] Linux
* [x] MacOS
* [x] Windows
* [ ] ~~Web（为什么不试试神奇的浏览器呢？）~~

> [!IMPORTANT]
>
> * iOS和MacOS平台的产物未经过测试。如有问题请提issue，不保证一定解决，欢迎提PR。
> * iOS和MacOS平台产物并未签名，ipa签名请自行寻找方法。

## 编译

``` shell
# 1. All
git clone --recursive https://github.com/realth000/tsdm_client
cd tsdm_client
dart run build_runner build

# 2. Android
flutter build apk --release

# 2. iOS
flutter build ios --release --no-codesign

# 2. Linux
flutter build linux --release

# 2. MacOS
flutter build macos --release

# 2. Windows
flutter build windows --release
```

## 隐私政策

本程序不会收集或上传任何系统或设备或用户信息，访问主站时使用的凭据均只保存在设备本地。

## 许可

本程序在[MIT License](./LICENSE)下分发。
