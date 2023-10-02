# tsdm_client

<div align="center">
    <p>
        <a href="https://github.com/realth000/tsdm_client/releases">
            <img src="https://img.shields.io/badge/-Android-313196?logo=android&logoColor=f0f0f0"/></a>
        <a href="https://github.com/realth000/tsdm_client/releases">
            <img src="https://img.shields.io/badge/-Linux-313196?&logo=Linux&logoColor=f0f0f0"/></a>
        <a href="https://github.com/realth000/tsdm_client/releases">
            <img src="https://img.shields.io/badge/-Windows-313196?&logo=Windows&logoColor=f0f0f0"/></a>
        <a href="https://flutter.dev/">
            <img src="https://img.shields.io/badge/Flutter-3.13-blue?logo=flutter"/></a>
        <a href="https://github.com/realth000/tsdm_client/blob/master/LICENSE">
            <img src="https://img.shields.io/github/license/realth000/tsdm_client"/></a>
    </p>
</div>

使用Flutter制作的天使动漫（TSDM）论坛非官方客户端。

## 功能

* [ ] 看贴
    * [x] 回复内容
    * [x] 基本信息（用户名、头像）
    * [ ] 其他信息（分组、徽章、心情等）
* [ ] 登录
    * [x] 登录
    * [ ] 带安全问题登录
    * [ ] 退出登录
* [ ] 搜索
* [ ] 回帖
* [ ] 购买帖子
* [ ] 签到
* [ ] 查看短消息
* [ ] 查看用户信息
* [ ] 省流模式（archiver)
* [ ] ...

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
