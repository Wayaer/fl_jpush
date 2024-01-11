## 4.1.0

* android添加消息删除回调支持,`onNotifyMessageDismiss`
* 区分通知和自定义消息回调 `JPushMessage`、`JPushNotificationMessage`,

## 4.0.2

* 修改`NotificationSettingsWithIOS`的部分默认值为`false`

## 4.0.1

* 全新升级，更新ios和android sdk至最新版,(集成厂商推送需要同步更新)
* 修改 `addEventHandler` 的回调，区分android和ios
* `sendLocalNotification` 区分android和ios
* 集成厂商推送的需要重新复制一下原生依赖包（heytap_msp_push和hi_push）
* `clearNotification` 新增 `delivered` 和 `clearLocal`参数

## 3.4.0

* Update Sdk version to 5.0.4

## 3.3.0+1

* Update Sdk version to 4.9.0
* If you are using `fl_jpush_android`, you must update to 3.3.0

## 3.2.0

* Update Sdk version to 4.8.1
* If you are using `fl_jpush_android`, you will also need to update to the latest

## 3.1.1

* Fixed MI push not receiving messages offline

## 3.0.6

* Fixed ios not sending local messages

## 3.0.5

* Upgrade Android jcore、jpush@4.7.2 SDK version

## 3.0.1

* Fix sending local messages

## 3.0.0

* Compatible with flutter 3.0.0

## 2.3.1

* Upgrade Android jcore、jpush SDK version

## 2.2.1

* Add result interception

## 2.2.0

* Update the SDK pushed by mobile phone manufacturers
* Upgrade Android jcore、jpush SDK version

## 2.1.2

* Fix bug for android

## 2.1.0

* Add vendor channel support
* Remove instance , direct initialization
* Update gradle version
* Update kotlin version

## 2.0.0

* Add Singleton Pattern
* Upgrade Android Gradle

## 1.0.0

* Add platform restrictions
* Upgrade Android jcore、jpush SDK version

## 0.3.0

* Fix bugs
* Override JPushMessage

## 0.2.8

* modify the return parameter to be non null
* Update Android version

## 0.2.7

* Update Android com.android.tools.build:gradle version
* Replace jcenter() to mavenCentral()

## 0.2.6

* Add Android proguard rules
* Fix the bug that validJPushTag has no return value

## 0.2.5

* Fix bugs

## 0.2.2

* Fix bugs for Android

## 0.2.1

* Normative approach
* Add doc

## 0.1.0

* Modify API name
* Update dart version to 2.12.1
* Support 2.0

## 0.0.1

* Init plugin