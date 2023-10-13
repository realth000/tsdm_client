<div align="center">
  <p>
    <h1>
      <a href="https://github.com/realth000/tsdm_client/">
        <img src="./assets/images/tsdm_client.svg" width="120px">
      </a>
      <br/>
      tsdm_client
    </h1>
    <h4>使用Flutter制作的天使动漫（tsdm39.com）论坛非官方客户端<h4/>
  </p>
  <p>
    <a href="https://github.com/realth000/tsdm_client/releases">
      <img src="https://img.shields.io/badge/-Android-19A6E6?logo=android&logoColor=f0f0f0"/>
    </a>
    <a href="https://github.com/realth000/tsdm_client/releases">
      <img src="https://img.shields.io/badge/-Linux-19A6E6?&logo=Linux&logoColor=f0f0f0"/>
    </a>
    <a href="https://github.com/realth000/tsdm_client/releases">
      <img src="https://img.shields.io/badge/-Windows-19A6E6?&logo=Windows&logoColor=f0f0f0"/>
    </a>
    <a href="https://flutter.dev/">
      <img src="https://img.shields.io/badge/Flutter-3.13-19A6E6?logo=flutter"/>
    </a>
    <a href="https://github.com/realth000/tsdm_client/blob/master/LICENSE">
      <img src="https://img.shields.io/github/license/realth000/tsdm_client"/>
    </a>
    <a href="https://app.codacy.com/gh/realth000/tsdm_client/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade">
      <img src="https://app.codacy.com/project/badge/Grade/cb1ee2e43746487798ced62cf0aee24b"/>
    </a>
  </p>
</div>
           
## 功能

* [ ] 看贴
  * [x] 回复内容
  * [x] 基本信息（用户名、头像）
  * [ ] 其他信息（分组、徽章、心情等）
* [ ] 登录
  * [x] 登录
  * [ ] 带安全问题登录
  * [x] 退出登录
* [ ] 搜索
* [ ] 回帖
* [ ] 购买帖子
* [x] 签到
* [x] 深色模式
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
