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

## 集成厂商通道

- [华为、小米、OPPO、VIVO、魅族]安装 [fl_jpush_android](https://pub.dev/packages/fl_jpush_android)
- [Google FCM]安装 [fl_jpush_android_fcm](https://pub.dev/packages/fl_jpush_android_fcm)

- 如集成国内厂商sdk 升级更新需参考 [fl_jpush_android](https://pub.dev/packages/fl_jpush_android) 升级

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
  FlJPush().addEventHandler(
      eventHandler: FlJPushEventHandler(
          onOpenNotification: (JPushNotificationMessage? message) {
            /// 点击通知栏消息回调
            log('onOpenNotification: ${message?.toMap()}');
          }, onReceiveNotification: (JPushNotificationMessage? message) {
        /// 接收普通消息
        log('onReceiveNotification: ${message?.toMap()}');
      }, onReceiveMessage: (JPushMessage? message) {
        /// 接收自定义消息
        log('onReceiveMessage: ${message?.toMap()}');
      }),
      androidEventHandler: FlJPushAndroidEventHandler(
          onCommandResult: (FlJPushCmdMessage message) {
            log('onCommandResult: ${message.toMap()}');
          }, onNotifyMessageDismiss: (JPushNotificationMessage? message) {
        /// onNotifyMessageDismiss
        /// 清除通知回调
        /// 1.同时删除多条通知，可能不会多次触发清除通知的回调
        /// 2.只有用户手动清除才有回调，调接口清除不会有回调
        log('onNotifyMessageDismiss: ${message?.toMap()}');
      }, onNotificationSettingsCheck:
          (FlJPushNotificationSettingsCheck? settingsCheck) {
        /// 通知开关状态回调
        /// 说明: sdk 内部检测通知开关状态的方法因系统差异，在少部分机型上可能存在兼容问题(判断不准确)。
        /// source 触发场景，0 为 sdk 启动，1 为检测到通知开关状态变更
        log('onNotificationSettingsCheck: ${settingsCheck?.toMap()}');
      }),
      iosEventHandler: FlJPushIOSEventHandler(
          onReceiveNotificationAuthorization: (bool? state) {
            /// ios 申请通知权限 回调
            log('onReceiveNotificationAuthorization: $state');
            text = 'onReceiveNotificationAuthorization: $state';
          }, onOpenSettingsForNotification: (JPushNotificationMessage? data) {
        /// 从应用外部通知界面进入应用是指 左滑通知->管理->在“某 App”中配置->进入应用 。
        /// 从通知设置界面进入应用是指 系统设置->对应应用->“某 App”的通知设置
        /// 需要先在授权的时候增加这个选项 JPAuthorizationOptionProvidesAppNotificationSettings
        log('onOpenSettingsForNotification: ${data?.toMap()}');
      }));
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
  final notificationID = DateTime
      .now()
      .millisecondsSinceEpoch;
  var localNotification = LocalNotification(
      id: notificationID,
      title: 'title',
      content: 'content',

      /// 3秒后发送
      fireTime: 3,
      badge: 5,
      extras: {'hh': '11'} // 设置 extras ，extras 需要是 Map<String, String>
  );
  FlJPush().sendLocalNotification(
      android: localNotification.toAndroid(buildId: 1,),
      ios: localNotification.toIOS(subtitle: 'subtitle',));
}
```

#### clearNotification

- 清空通知栏上的通知

```dart

Future<void> fun() async {
  /// 清空通知栏上某个通知
  bool? status = await FlJPush().clearNotification(notificationId: notificationId);

  /// 清空通知栏上全部通知
  bool? status = await FlJPush().clearNotification();

  /// 清空通知栏上全部本地通知 仅支持android
  bool? status = await FlJPush().clearNotification(clearLocal: true);

  /// 清空通知栏上全部待推送的通知 仅支持ios
  bool? status = await FlJPush().clearNotification(delivered: false);
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

#### setBadge

- 设置应用 badge 值，该方法还会同步 JPush 服务器的的 badge 值，JPush 服务器的 badge 值用于推送 badge 自动 +1 时会用到。

```dart

void fun() {
  FlJPush().setBadge(66).then((bool? status) {});
}
```

** android Only **

#### getAndroidUdID

- 获取UDID

```dart

Future<void> fun() async {
  String? udid = await FlJPush().getUDIDWithAndroid();
}
```

** iOS Only **

#### applyAuthorityWithIOS

- 申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。

**注意： iOS10+ 可以通过该方法来设置推送是否前台展示，是否触发声音，是否设置应用角标 badge**

```dart
void fun() {
  FlJPush().applyAuthorityWithIOS(NotificationSettingsWithIOS(
      sound: true,
      alert: true,
      badge: true));
}
```

### getLaunchAppNotificationWithIOS

- 获取 iOS 点击推送启动应用的那条通知。

```dart

void fun() {
  FlJPush().getLaunchAppNotificationWithIOS().then((Map<dynamic, dynamic>? map) {});
}
```

