# JPush Flutter Plugin

### 配置

### Android:

- 在 `/android/app/src/main/res/values/strings.xml` 中添加下列代码：（没有strings.xml 手动创建）

```xml

<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">App Name</string>
</resources>

```

在 `example/android/app/src/main/AndroidManifest.xml` 中添加下列代码：

```xml

<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.jpush.example">
    <application android:label="@string/app_name">

        ...

    </application>
</manifest>

```

- 在 `/android/app/build.gradle` 中添加下列代码：

```groovy
android:
{

    defaultConfig {
        applicationId '自己应用 ID'
        manifestPlaceholders = [
                JPUSH_PKGNAME : applicationId,
                JPUSH_APPKEY  : 'appkey',
                JPUSH_CHANNEL : 'developer-default',

                // 如集成厂商通道，请添加以下信息
                MEIZU_APPKEY  : "MZ-",
                MEIZU_APPID   : "MZ-",
                XIAOMI_APPID  : "MI-",
                XIAOMI_APPKEY : "MI-",
                OPPO_APPKEY   : "OP-",
                OPPO_APPID    : "OP-",
                OPPO_APPSECRET: "OP-",
                VIVO_APPKEY   : "",
                VIVO_APPID    : "",
                HUAWEI_APPID  : "配置文件里的appid",
                HUAWEI_CPID   : "配置文件里的cp_id"
        ]
    }
}
```

- 集成厂商通道的 安装 [fl_jpush_android](https://pub.dev/packages/fl_jpush_android)

### iOS:

Capability 添加 "Background Modes"  "Push Notifications"
并保证"Background Modes"中的"Remote notifications"处于选中状态

### 使用

```dart
import 'package:fl_jpush/fl_jpush_dart';
```

### APIs

**注意** : 需要先调用 setup 来初始化插件，才能保证其他功能正常工作。

#### addEventHandler

- 添加事件监听方法。

```dart

Future<void> addEventHandler() async {
  FlJPush().addEventHandler(onReceiveNotification: (JPushMessage? message) {
    print('onReceiveNotification: ${message?.toMap}');
  }, onOpenNotification: (JPushMessage? message) {
    print('onOpenNotification: ${message?.toMap}');
  }, onReceiveMessage: (JPushMessage? message) {
    print('onReceiveMessage: ${message?.toMap}');
  }, onReceiveNotificationAuthorization: (JPushMessage? message) {
    print('onReceiveNotificationAuthorization: ${message?.toMap}');
  });
}

```

#### setup

- 添加初始化方法，调用 setup 方法会执行两个操作：

**注意：**  android 端支持在 setup 方法中动态设置 channel，动态设置的 channel 优先级比 manifestPlaceholders 中的 JPUSH_CHANNEL 优先级要高。

```dart

@override
void initState() {
  super.initState();

  /// 初始化
  FlJPush().setup(
      iosKey: 'AppKey', //你自己应用的 AppKey
      production: false,
      channel: 'channel',
      debug: false);
}
```

#### getRegistrationID

- 获取 registrationId，JPush 运行通过 registrationId 来进行推送.

```dart
 void getRegistrationID() {
  FlJPush().getRegistrationID().then((String? rid) {
    print('get registration id : $rid');
  });
}
```

#### stop

- 停止推送功能，调用该方法将不会接收到通知。

```dart

void fun() {
  FlJPush().stop();
}
```

#### resume

- 调用 stop 后，可以通过 resume 方法恢复推送。

```dart
void fun() {
  FlJPush().resume();
}
```

#### setAlias

- 设置别名，极光后台可以通过别名来推送，一个 App 应用只有一个别名，一般用来存储用户 id。

```dart
void fun() {
  FlJPush().setAlias('your alias').then((AliasResultModel? model) {});
}
```

#### deleteAlias

- 删除 alias。

```dart

void fun() {
  FlJPush().deleteAlias().then((AliasResultModel? model) {});
}
```

#### getAlias

- 获取 alias.

```dart
void fun() {
  FlJPush().getAlias().then((AliasResultModel? model) {});
}
```

#### addTags

- 在原来的 Tags 列表上添加指定 tags。

```dart
void fun() {
  FlJPush().addTags(['tag1', 'tag2']).then((TagResultModel? model) {});
}
```

#### deleteTags

- 在原来的 Tags 列表上删除指定 tags。

```dart
void fun() {
  FlJPush().deleteTags(['tag1', 'tag2']).then((TagResultModel? model) {});
}
```

#### setTags

- 重置 tags。

```dart

void fun() {
  FlJPush().setTags(['tag1', 'tag2']).then((TagResultModel? model) {});
}
```

#### validTag

- 验证tag是否绑定。

```dart
void fun() {
  FlJPush().validTag('tag1').then((TagResultModel? model) {});
}
```

#### cleanTags

- 清空所有 tags

```dart
void fun() {
  FlJPush().cleanTags().then((TagResultModel? model) {});
}
```

#### getAllTags

- 获取当前 tags 列表。

```dart
void fun() {
  FlJPush().getAllTags().then((TagResultModel? model) {});
}

```

#### sendLocalNotification

- 指定触发时间，添加本地推送通知。

```dart
/// 延时 3 秒后触发本地通知。
void fun() {
  var fireDate = DateTime.fromMillisecondsSinceEpoch(DateTime
      .now()
      .millisecondsSinceEpoch + 3000);
  var localNotification = LocalNotification(
      id: 222,
      title: 'title',
      buildId: 1,
      content: 'content',
      fireTime: fireDate,
      subtitle: 'subtitle',
      // 该参数只有在 iOS 有效
      badge: 5,
      // 该参数只有在 iOS 有效
      extras: {'hh': '11'} // 设置 extras ，extras 需要是 Map<String, String>
  );
  FlJPush().sendLocalNotification(localNotification).then((localNotification) {});
}
```

#### clearNotification

- 清空通知栏上某个通知

```dart

Future<void> fun() async {
  bool? status = await FlJPush().clearNotification(notificationId);
}
```

#### clearAllNotifications

- 清楚通知栏上所有通知。

```dart

Future<void> fun() async {
  FlJPush().clearAllNotifications();
}
```

#### isNotificationEnabled

- 检测通知授权状态是否打开

```dart
Future<void> fun() async {
  bool? status = await FlJPush().isNotificationEnabled();
}
```

**Android Only **

#### isStopped

- Push Service 是否已经被停止

```dart
Future<void> fun() async {
  bool? status = await FlJPush().isPushStopped();
}
```

#### getAndroidUdID

- 获取UDID

```dart

Future<void> fun() async {
  String? udid = await FlJPush().getUDIDWithAndroid();
}
```

**iOS Only **

#### applyAuthorityWithIOS

- 申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。

**注意： iOS10+ 可以通过该方法来设置推送是否前台展示，是否触发声音，是否设置应用角标 badge**

```dart
void fun() {
  FlJPush().applyAuthorityWithIOS(NotificationSettingsIOS(
      sound: true,
      alert: true,
      badge: true));
}
```

#### setBadge

- 设置应用 badge 值，该方法还会同步 JPush 服务器的的 badge 值，JPush 服务器的 badge 值用于推送 badge 自动 +1 时会用到。

```dart

void fun() {
  FlJPush().setBadge(66).then((bool? status) {});
}
```

### getLaunchAppNotificationWithIOS

- 获取 iOS 点击推送启动应用的那条通知。

```dart

void fun() {
  FlJPush().getLaunchAppNotificationWithIOS().then((Map<dynamic, dynamic>? map) {});
}
```

