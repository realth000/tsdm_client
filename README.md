<h1 align="center">
    <a href="https://github.com/realth000/tsdm_client/">
        <img src="./assets/images/tsdm_client.svg" width="120px" alt="tsdm_client_logo">
    </a>
    <br>
    tsdm_client
</h1>

<p align="center">
天使动漫论坛第三方跨平台客户端
</p>

<p align="center">
  <a href="https://github.com/realth000/tsdm_client/actions"><img src="https://img.shields.io/github/actions/workflow/status/realth000/tsdm_client/test.yml?label=test" alt="test_ci"/></a>
  <a href="https://github.com/realth000/tsdm_client/releases"><img src="https://img.shields.io/github/release/realth000/tsdm_client?label=stable" alt="stable_version"></a>
  <a href="https://github.com/realth000/tsdm_client/releases"><img src="https://img.shields.io/github/release/realth000/tsdm_client?label=preview&include_prereleases" alt="preview_version"></a>
  <a href="https://github.com/realth000/tsdm_client/releases"><img src="https://img.shields.io/badge/platform-Android_%7C_iOS_%7C_Linux_%7C_macOS_%7C_Windows-19A6E6" alt="platforms"></a>
  <a href="https://github.com/realth000/tsdm_client/releases"><img src="https://img.shields.io/github/downloads/realth000/tsdm_client/total" alt="download_total"></a>
  <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-3.24-19A6E6?logo=flutter" alt="flutter_version"></a>
  <a href="https://dart.dev/"><img src="https://img.shields.io/github/languages/top/realth000/tsdm_client?logo=dart" alt="dart_percentage"/></a>
  <a href="https://app.codacy.com/gh/realth000/tsdm_client/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade"><img src="https://app.codacy.com/project/badge/Grade/28ffb16db1ba4d8a943d9feba3a402b3" alt="codacy_code_analyze"></a>
  <a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="vga_lint"></a>
</p>

> [!TIP]
>
> 受测试条件限制，标注为已实现的功能也可能有缺陷，欢迎提issue或PR。

## 截图

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img width="100%" src="./doc/pic/screenshot_01.png" alt="screenshot_01">
      </td>
      <td align="center">
        <img width="100%" src="./doc/pic/screenshot_02.png" alt="screenshot_02">
      </td>
    </tr>
    <tr>
      <td align="center">
        <img width="100%" src="./doc/pic/screenshot_03.png" alt="screenshot_03">
      </td>
      <td align="center">
        <img width="100%" src="./doc/pic/screenshot_04.png" alt="screenshot_04">
      </td>
    </tr>
  </table>
</div>

## 下载

**从v0.x版本升级到v1.x版本会失去登录状态并重置设置**

有关v1.0.0版本的功能计划，详见[#3](https://github.com/realth000/tsdm_client/issues/3)

**v1.0预览版引入了很多特性并修复了非常多的问题，建议直接使用预览版**

**v1.0预览版的变更可在更新日志的[UNRELEASED](https://github.com/realth000/tsdm_client/blob/master/CHANGELOG.md#unreleased)小节中查看**

<div align="left">
  <table>
    <thead align="left">
     <tr>
       <th>系统</th>
       <!-- <th>稳定版（0.14）</th> -->
       <th>预览版（1.0.0-alpha.10）</th>
     </tr>
    </thead>
  <tbody>
    <tr>
      <td>Android</td>
      <!-- <td> -->
        <!-- <a href="https://github.com/realth000/tsdm_client/releases/latest/download/tsdm_client-arm64_v8a.apk"><img src="https://img.shields.io/badge/apk-arm64--v8a-blue.svg?logo=android&logoColor=white" alt="stable_apk_armv8"/></a><br> -->
        <!-- <a href="https://github.com/realth000/tsdm_client/releases/latest/download/tsdm_client-armeabi_v7a.apk"><img src="https://img.shields.io/badge/apk-armeabi--v7a-blue.svg?logo=android&logoColor=white" alt="stable_apk_armv7"/></a><br> -->
      <!-- </td> -->
      <td>
        <a href="https://github.com/realth000/tsdm_client/releases/download/v1.0.0-alpha.10/tsdm_client-arm64_v8a.apk"><img src="https://img.shields.io/badge/apk-arm64--v8a-orange.svg?logo=android&logoColor=white" alt="preview_apk_armv8"/></a><br>
        <a href="https://github.com/realth000/tsdm_client/releases/download/v1.0.0-alpha.10/tsdm_client-armeabi_v7a.apk"><img src="https://img.shields.io/badge/apk-armeabi--v7a-orange.svg?logo=android&logoColor=white" alt="preview_apk_armv7"/></a><br>
      </td>
    </tr>
    <tr>
      <td>iOS</td>
      <!-- <td> -->
        <!-- <a href="https://github.com/realth000/tsdm_client/releases/latest/download/tsdm_client.ipa"><img src="https://img.shields.io/badge/ipa-universal-blue.svg?logo=ios&logoColor=white" alt="stable_ipa_universal"/></a><br> -->
      <!-- </td> -->
      <td>
        <a href="https://github.com/realth000/tsdm_client/releases/download/v1.0.0-alpha.10/tsdm_client.ipa"><img src="https://img.shields.io/badge/ipa-universal-orange.svg?logo=ios&logoColor=white" alt="preview_ipa_universal"/></a>
      </td>
    </tr>
    <tr>
      <td>Linux</td>
      <!-- <td> -->
        <!-- <a href="https://github.com/realth000/tsdm_client/releases/latest/download/tsdm_client-linux.tar.gz"><img src="https://img.shields.io/badge/tar.gz-x86__64-blue.svg?logo=linux&logoColor=white" alt="stable_targz_x64"/></a><br> -->
      <!-- </td> -->
      <td>
        <a href="https://github.com/realth000/tsdm_client/releases/download/v1.0.0-alpha.10/tsdm_client-linux.tar.gz"><img src="https://img.shields.io/badge/tar.gz-x86__64-orange.svg?logo=linux&logoColor=white" alt="preview_targz_x64"/></a><br>
      </td>
    </tr>
    <tr>
      <td>macOS</td>
      <!-- <td> -->
        <!-- <a href="https://github.com/realth000/tsdm_client/releases/latest/download/tsdm_client-universal.dmg"><img src="https://img.shields.io/badge/dmg-universal-blue.svg?logo=apple&logoColor=white&logoColor=white" alt="stable_dmg_universal"/></a><br> -->
      <!-- </td> -->
      <td>
        <a href="https://github.com/realth000/tsdm_client/releases/download/v1.0.0-alpha.10/tsdm_client-universal.dmg"><img src="https://img.shields.io/badge/dmg-universal-orange.svg?logo=apple&logoColor=white" alt="preview_dmg_universal"/></a>
      </td>
    </tr>
    <tr>
      <td>Web</td>
      <!-- <td> -->
        <!-- <img src="https://img.shields.io/badge/zip-coming%20soon-c0c0c0.svg?logo=webassembly&logoColor=white" alt="stable_zip_wasm"/><br> -->
        <!-- <img src="https://img.shields.io/badge/zip-coming%20soon-c0c0c0.svg?logo=javascript&logoColor=white" alt="stable_zip_js"/> -->
      <!-- </td> -->
      <td>
        <img src="https://img.shields.io/badge/zip-coming%20soon-c0c0c0.svg?logo=webassembly&logoColor=white" alt="preview_zip_wasm"/><br>
        <img src="https://img.shields.io/badge/zip-coming%20soon-c0c0c0.svg?logo=javascript&logoColor=white" alt="preview_zip_js"/>
      </td>
    </tr>
    <tr>
      <td>Windows</td>
      <!-- <td> -->
        <!-- <a href="https://github.com/realth000/tsdm_client/releases/latest/download/tsdm_client-windows.zip"><img src="https://img.shields.io/badge/zip-x86__64-blue.svg?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA0ODc1IDQ4NzUiPg0KICAgIDxwYXRoIGZpbGw9IiNmZmYiIGQ9Ik0wIDBoMjMxMXYyMzEwSDB6bTI1NjQgMGgyMzExdjIzMTBIMjU2NHpNMCAyNTY0aDIzMTF2MjMxMUgwem0yNTY0IDBoMjMxMXYyMzExSDI1NjQiLz4NCjwvc3ZnPg==" alt="stable_zip_win"/></a><br> -->
      <!-- </td> -->
      <td>
        <a href="https://github.com/realth000/tsdm_client/releases/download/v1.0.0-alpha.10/tsdm_client-windows.zip"><img src="https://img.shields.io/badge/zip-x86__64-orange.svg?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA0ODc1IDQ4NzUiPg0KICAgIDxwYXRoIGZpbGw9IiNmZmYiIGQ9Ik0wIDBoMjMxMXYyMzEwSDB6bTI1NjQgMGgyMzExdjIzMTBIMjU2NHpNMCAyNTY0aDIzMTF2MjMxMUgwem0yNTY0IDBoMjMxMXYyMzExSDI1NjQiLz4NCjwvc3ZnPg==" alt="preview_zip_win"/></a><br>
      </td>
    </tr>
  </tbody>
  </table>
</div>

> [!TIP]
>
> * iOS和macOS平台的产物没有测试环境，未经过测试，欢迎提issue和PR。
> * iOS和macOS平台产物并未签名，ipa签名请自行寻找方法。

## 功能

*斜体字功能目前只存在于预览版*

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
  * [x] 我的帖子
  * [x] 查看新帖
  * [x] 帖子类型（加精，置顶，已关闭等）
  * [x] 置顶帖
  * [x] 领取红包
  * [x] 悬赏/悬赏答案
  * [x] 积分信息
  * [ ] 签到信息
  * [ ] 勋章
  * [ ] 签名档
  * [x] 查看图片
* [x] 回帖
  * [x] 回复文字
  * [x] 回复其他楼层
  * [x] 编辑回复
  * [x] 编辑帖子（一楼）
  * [x] [富文本模式](#富文本支持)
* [x] 编辑帖子
  * [x] 修改纯文本内容
  * [x] 设置分类和标题
  * [x] 设置附加选项
  * [x] *设置阅读权限*
  * [x] *设置售价*
  * [x] [富文本模式](#富文本支持)
* [x] 发帖
  * [x] *纯文本内容*
  * [x] *保存为草稿*
  * [x] *编辑草稿*
  * [ ] 本地自动保存
  * [x] *设置分类和标题*
  * [x] *设置附加选项*
  * [x] *设置阅读权限*
  * [x] *设置售价*
  * [x] *[富文本模式](#富文本支持)*
* [x] 登录
  * [x] 用户名登录
  * [x] *UID或邮箱登录*
  * [x] 带安全问题登录
  * [x] 登录一次后cookie自动登录
  * [x] 退出登录
  * [x] 多账户登录
* [x] 搜索
  * [x] 按作者id和论坛id搜索
* [x] 积分
  * [x] 积分统计和历史记录
  * [x] 查询积分记录
* [ ] 购买
  * [x] 购买帖子
  * [x] 回复后可见
  * [ ] 购买记录
* [x] 签到
  * [x] 手动签到
  * [x] 自动签到（为所有用户）
* [x] 深色模式
  * [x] 手动设置
  * [x] 跟随系统
  * [x] *自动调整帖子内的颜色*
* [x] 主题
  * [x] 更换主题色
  * [x] *动态颜色*
* [ ] 用户信息
  * [x] 查看用户信息
  * [x] 积分信息
  * [x] 签名档
  * [ ] 修改头像
  * [ ] 修改个人资料
* [x] 通知
  * [x] 查看提醒
  * [x] 回复提醒
  * [x] 跳转到提醒的帖子
  * [x] 查看私信/系统消息
  * [x] 查看私信对话历史
  * [x] 回复私信
  * [x] 发送私信
  * [x] 发送富文本私信
* [ ] 好友
  * [ ] 加好友
  * [ ] 查看好友
  * [ ] 分组
  * [ ] 删除
* [x] 应用内更新
* [ ] 收藏
  * [ ] 收藏帖子或分区
  * [ ] RSS订阅
* [ ] 多用户
* [ ] 多语言
  * [x] 软件界面
  * [ ] 浏览内容翻译为繁体中文
* [ ] ...

### 不实现的功能

**考虑到安全性和测试条件，以下功能不会实现**

* 账号安全：更改密码、更换邮箱和设置安全问题。
* 版主权限：帖子操作、用户操作和版区操作等。
* 存储：保存登录密码或安全问题。

## 富文本支持

### 概述

目前正在添加bbcode的富文本支持，最终会在发表帖子/回复/消息等场景内支持所见即所得的bbcode书写体验。

BBCode编辑器主要功能存放在单独的仓库[flutter_bbcode_editor](https://github.com/realth000/flutter_bbcode_editor)中。

### 进度

**[BBCode编辑器](https://github.com/realth000/flutter_bbcode_editor)仍处于试验阶段**

*斜体字功能目前只存在于预览版*

* [x] 文本样式
  * [x] *字号（固定大小1-7）*
  * [x] 字体颜色
  * [x] 背景颜色
  * [x] 粗体
  * [x] 斜体
  * [x] 下划线
  * [x] 删除线
  * ~~字体~~（不实现）
* [x] 表情
* [x] *网页链接*
  * [x] 添加
  * [x] *修改*
* [x] 外链图片
  * [x] 添加
  * [x] 设置大小
  * [x] *修改*
* [x] *折叠卡片*
* [ ] 隐藏内容
* [x] *代码块*
* [x] *引用文字*
* [ ] 分隔线
* [x] 提醒用户（@）
  * [x] *根据用户名搜索*
  * [x] *随机推荐好友*
* [x] *无序列表*
* [x] *有序列表*
* [ ] 表格
* [ ] 上标
* [x] 对齐（居左/居中/居右）

## 已知问题

~~在修了在修了~~

* 暂不支持论坛的`璀璨星河`主题，请不要在设置中使用该主题。
* 长时间使用至cookie过期时一些功能可能无法使用，例如签到，此时请重新登录。

## 开发

### 编译

``` shell
# 1. All
git clone --recursive https://github.com/realth000/tsdm_client
cd tsdm_client
dart run build_runner build

# 2. Android
flutter build apk

# 2. iOS
flutter build ios --no-codesign

# 2. Linux
flutter build linux

# 2. macOS
flutter build macos

# 2. Web
# 2.1 编译到wasm
flutter build web --wasm
# 2.2 编译到js
flutter build web

# 2. Windows
flutter build windows
```

### 更新数据库schema

```bash
# Export schema
dart run drift_dev schema dump lib/shared/providers/storage_provider/models/database/database.dart lib/shared/providers/storage_provider/models/database/schema/migration/
# Generate migration
dart run drift_dev schema steps lib/shared/providers/storage_provider/models/database/schema/migration/ lib/shared/providers/storage_provider/models/database/schema/schema_versions.dart
# Update schema for test
dart run drift_dev schema generate lib/shared/providers/storage_provider/models/database/schema/migration/ test/data/generated_migrations/
```

## 隐私

本程序不会收集或上传任何系统或设备或用户信息，访问主站时使用的凭据均只保存在设备本地。

* 保存用户信息，包括用户名、UID和cookie供登录和访问时使用。
* 不会保存邮箱、密码和安全问题。

## 许可

本程序在[MIT License](./LICENSE)下分发。
