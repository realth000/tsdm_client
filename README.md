<div align="center">
  <p>
    <h1>
      <a href="https://github.com/realth000/tsdm_client/">
        <img src="./assets/images/tsdm_client.svg" width="120px">
      </a>
      <br>
      tsdm_client
    </h1>
    <h4>使用Flutter制作的天使动漫（tsdm39.com）论坛非官方客户端</h4>
  </p>
  <p>
    <a href="https://github.com/realth000/tsdm_client/releases">
      <img src="https://img.shields.io/badge/-Android-19A6E6?logo=android&logoColor=f0f0f0">
    </a>
    <a href="https://github.com/realth000/tsdm_client/releases">
      <img src="https://img.shields.io/badge/-Linux-19A6E6?&logo=Linux&logoColor=f0f0f0">
    </a>
    <a href="https://github.com/realth000/tsdm_client/releases">
      <img src="https://img.shields.io/badge/-Windows-19A6E6?&logo=Windows&logoColor=f0f0f0">
    </a>
    <a href="https://flutter.dev/">
      <img src="https://img.shields.io/badge/Flutter-3.13-19A6E6?logo=flutter">
    </a>
    <a href="https://github.com/realth000/tsdm_client/blob/master/LICENSE">
      <img src="https://img.shields.io/github/license/realth000/tsdm_client">
    </a>
    <a href="https://app.codacy.com/gh/realth000/tsdm_client/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade">
      <img src="https://app.codacy.com/project/badge/Grade/cb1ee2e43746487798ced62cf0aee24b">
    </a>
  </p>
</div>

> **Note**
>
> 所有功能实现均依靠解析公开的网页，仅与主站间有和网页端浏览相似的流量，数据均存储在本地设备，不会收集或上传任何信息到任何服务器。

## 功能

* [ ] 看贴
    * [x] 回复内容
    * [x] 基本信息（用户名、头像）
    * [ ] 其他信息（分组、徽章、心情等）
    * [ ] 复制内容
    * [ ] 回复时引用的内容
    * [ ] 投票
    * [ ] 代码块
* [ ] 登录
    * [x] 登录
    * [ ] 用户名或邮箱登录
    * [ ] 带安全问题登录
    * [x] 退出登录
* [ ] 搜索
* [ ] 回帖
    * [x] 回复文字
    * [ ] 设置字体、字号、链接等富文本
    * [ ] 回复具体楼层
    * [ ] 编辑或删除回复
* [ ] 购买帖子
* [x] 签到
* [x] 深色模式
* [ ] 提醒和消息
    * [ ] 查看消息
    * [ ] 跳转到对应帖子
    * [ ] 直接回复消息
* [ ] 查看用户信息
* [ ] 省流模式（解析archiver或移动版UI)
* [ ] ...

## 已知问题

~~在修了在修了~~

* 根据不同地区不同的网络情况，启动时加载时间可能会较长。
* 暂不支持论坛的`璀璨星河`和`旅行者`主题，请不要在设置中使用这两个主题风格。
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
