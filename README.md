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
  <a href="https://github.com/realth000/tsdm_client/actions"><img src="https://img.shields.io/github/actions/workflow/status/realth000/tsdm_client/test_build.yml?label=build"/></a>
  <a href="https://github.com/realth000/tsdm_client/releases"><img src="https://img.shields.io/github/release/realth000/tsdm_client"></a>
  <a href="https://github.com/realth000/tsdm_client/releases"><img src="https://img.shields.io/badge/-Android-19A6E6?logo=android&logoColor=f0f0f0"></a>
  <a href="https://github.com/realth000/tsdm_client/releases"><img src="https://img.shields.io/badge/-Linux-19A6E6?&logo=Linux&logoColor=f0f0f0"></a>
  <a href="https://github.com/realth000/tsdm_client/releases"><img src="https://img.shields.io/badge/-Windows-19A6E6?&logo=Windows&logoColor=f0f0f0"></a>
  <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-3.16-19A6E6?logo=flutter"></a>
  <a href="https://app.codacy.com/gh/realth000/tsdm_client/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade"><img src="https://app.codacy.com/project/badge/Grade/28ffb16db1ba4d8a943d9feba3a402b3"></a>
  <a href="https://github.com/realth000/tsdm_client/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-19A6E6"></a>
</p>

> **Note**
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

## 功能

* [ ] 看贴
  * [x] 回复
  * [x] 基本信息（用户名、头像）
  * [ ] 其他信息（分组、徽章、心情等）
  * [x] 链接跳转
  * [x] 电梯直达
  * [x] 展开/折叠
  * [x] 引用
  * [ ] 投票
  * [x] 查看点评
  * [ ] 点评
  * [x] 查看评分
  * [ ] 评分
  * [x] 代码块
  * [ ] 复制
  * [x] 我的帖子
  * [x] 查看新帖
  * [x] 帖子类型（加精，置顶，已关闭等）
* [ ] 登录
  * [x] 用户名登录
  * [ ] UID或邮箱登录
  * [x] 带安全问题登录
  * [x] 登录一次后cookie自动登录
  * [x] 退出登录
* [x] 搜索
  * [x] 按作者id和论坛id搜索
* [ ] 回帖
  * [x] 回复文字
  * [ ] 设置字体、字号、链接等
  * [x] 回复其他楼层
  * [ ] 编辑回复
* [ ] 购买帖子
  * [x] 购买
  * [x] 回复后可见
* [x] 签到
* [x] 深色模式
  * [ ] 自动调整暗色字体颜色
* [x] 更换色调
* [ ] 提醒和消息
  * [x] 查看提醒
  * [x] 回复提醒
  * [x] 跳转到提醒的帖子
  * [ ] 查看消息
  * [ ] 回复消息
* [x] 查看用户信息
  * [ ] 发消息
* [ ] 省流模式
* [x] 应用内更新
* [ ] ...

## 已知问题

~~在修了在修了~~

* 根据不同地区不同的网络情况，启动时加载时间可能会较长。
* 暂不支持论坛的`璀璨星河`主题，请不要在设置中使用该主题。
* 受限于解析和排布html节点的方式，少部分包含复杂回复楼层的帖子打开会**严重卡顿**。

## 支持平台

* [x] Android
* [ ] IOS
* [x] Linux
* [ ] MacOS
* [x] Windows
* [ ] ~~Web（为什么不试试神奇的浏览器呢？）~~

## 编译

``` shell
dart run build_runner build
flutter build windows/linux/apk --release
```

## 隐私政策

本程序不会收集或上传任何系统或设备或用户信息，访问主站时使用的凭据均只保存在设备本地。

## 许可

本程序在[MIT License](./LICENSE)下分发。
