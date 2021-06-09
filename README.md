# JPush Flutter Plugin

### 配置

##### Android:

在 `/android/app/src/main/res/values/strings.xml` 中添加下列代码：（没有strings.xml 手动创建）
```xml

<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">App Name</string>
</resources>

```
在 `example/android/app/src/main/AndroidManifest.xml` 中添加下列代码：
```xml

<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.jpush.example">
   <application
        android:label="@string/app_name" >

           ...

    </application>
</manifest>

```
在 `/android/app/build.gradle` 中添加下列代码：

```groovy
android: {

  defaultConfig {
    applicationId '自己应用 ID'

    manifestPlaceholders = [
        JPUSH_PKGNAME : applicationId,
        JPUSH_APPKEY : 'appkey', 
        
        JPUSH_CHANNEL : 'developer-default', 
        // 下面是多厂商配置，如需要开通使用请联系技术支持
        // 如果不需要使用，预留空字段即可
        MEIZU_APPKEY : "",
        MEIZU_APPID : "",
        XIAOMI_APPID : "",
        XIAOMI_APPKEY : "",
        OPPO_APPKEY : "",
        OPPO_APPID : "",
        OPPO_APPSECRET : "",
        VIVO_APPKEY : "",
        VIVO_APPID : ""
    ]
  }    
}
```

##### iOS:
 Capability 添加 "Background Modes"  "Push Notifications"
 并保证"Background Modes"中的"Remote notifications"处于选中状态

### 使用

```dart
import 'package:fl_jpush/fl_jpush_dart';
```

### APIs

**注意** : 需要先调用 setupJPush 来初始化插件，才能保证其他功能正常工作。

#### addJPushEventHandler

- 添加事件监听方法。

```dart

  Future<void> addJPushEventHandler() async {
    addJPushEventHandler(onReceiveNotification: (JPushMessage? message) {
      print('onReceiveNotification: ${message?.toMap}');
      text = 'onReceiveNotification: ${message?.title}';
      setState(() {});
    }, onOpenNotification: (JPushMessage? message) {
      print('onOpenNotification: ${message?.toMap}');
      text = 'onOpenNotification: ${message?.title}';
      setState(() {});
    }, onReceiveMessage: (JPushMessage? message) {
      print('onReceiveMessage: ${message?.toMap}');
      text = 'onReceiveMessage: ${message?.title}';
      setState(() {});
    }, onReceiveNotificationAuthorization: (JPushMessage? message) {
      print('onReceiveNotificationAuthorization: ${message?.toMap}');
      text = 'onReceiveNotificationAuthorization: ${message?.title}';
      setState(() {});
    });

  }

```

#### setupJPush

- 添加初始化方法，调用 setupJPush 方法会执行两个操作：

**注意：**  android 端支持在 setupJPush 方法中动态设置 channel，动态设置的 channel 优先级比 manifestPlaceholders 中的 JPUSH_CHANNEL 优先级要高。
```dart

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  /// 初始化
  setupJPush(
      iosKey: 'AppKey', //你自己应用的 AppKey
      production: false,
      channel: 'channel',
      debug: false);

  runApp(MaterialApp());

}
```

#### getRegistrationID

- 获取 registrationId，这个 JPush 运行通过 registrationId 来进行推送.

```dart
 void getRegistrationID (){

   getJPushRegistrationID().then((String? rid) {
      print('get registration id : $rid');
    });

  }
```

#### stopJPush

- 停止推送功能，调用该方法将不会接收到通知。

```dart

void fun()  {

    stopJPush();

}
```

#### resumeJPush

- 调用 stopJPush 后，可以通过 resumeJPush 方法恢复推送。

```dart
void fun()  {

    resumeJPush();

}
```

#### setJPushAlias

- 设置别名，极光后台可以通过别名来推送，一个 App 应用只有一个别名，一般用来存储用户 id。

```dart
void fun()  {

    setJPushAlias('your alias').then((AliasResultModel? model) { });

}
```

#### deleteJPushAlias

- 删除 alias。

```dart

void fun()  {

    deleteJPushAlias().then((AliasResultModel? model) {});

}
```


#### getJPushAlias

- 获取 alias.

```dart
void fun()  {

    getJPushAlias().then((AliasResultModel? model) {});

}
```

#### addJPushTags

- 在原来的 Tags 列表上添加指定 tags。

```dart
void fun()  {

    addJPushTags(['tag1','tag2']).then((TagResultModel? model) {});

}
```

####  deleteJPushTags

- 在原来的 Tags 列表上删除指定 tags。

```dart
void fun()  {

    deleteJPushTags(['tag1','tag2']).then((TagResultModel? model) {});

}
```

#### setJPushTags

- 重置 tags。

```dart

void fun()  {

    setJPushTags(['tag1','tag2']).then((TagResultModel? model) {});

}
```

#### validJPushTag

- 验证tag是否绑定。

```dart
void fun()  {

    validJPushTag('tag1').then((TagResultModel? model) {});

}
```

#### cleanJPushTags

- 清空所有 tags

```dart
void fun()  {

    cleanJPushTags().then((TagResultModel? model) {});

}
```

#### getAllJPushTags

- 获取当前 tags 列表。

```dart
void fun()  {

    getAllJPushTags().then((TagResultModel? model) {});

}

```

#### sendJPushLocalNotification

- 指定触发时间，添加本地推送通知。

```dart
/// 延时 3 秒后触发本地通知。
void fun()  {

    var fireDate = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + 3000);
     var localNotification = LocalNotification(
       id: 222,
       title: 'title',
       buildId: 1,
       content: 'content',
       fireTime: fireDate,
       subtitle: 'subtitle', // 该参数只有在 iOS 有效
       badge: 5, // 该参数只有在 iOS 有效
       extras: {'hh': '11'} // 设置 extras ，extras 需要是 Map<String, String>
  );
    sendJPushLocalNotification(localNotification).then((localNotification) {});

}
```

#### clearJPushNotification

- 清空通知栏上某个通知

```dart

Future<void> fun() async {

    bool? status = await clearJPushNotification(notificationId);

}
```


#### clearAllJPushNotifications

- 清楚通知栏上所有通知。

```dart

Future<void> fun() async {

    clearAllJPushNotifications();

}
```


#### isNotificationEnabled

- 检测通知授权状态是否打开

```dart
Future<void> fun() async {

    bool? status = await isNotificationEnabled();

}
```

**Android Only **


#### isJPushStopped

- Push Service 是否已经被停止

```dart
Future<void> fun() async {

    bool? status = await isJPushStopped();

}
```

#### getAndroidJPushUdID

- 获取UDID

```dart

Future<void> fun() async {

    String? udid = await getAndroidJPushUdID();

}
```


**iOS Only **

#### applyJPushAuthority

- 申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。

**注意： iOS10+ 可以通过该方法来设置推送是否前台展示，是否触发声音，是否设置应用角标 badge**

```dart
void fun()  {

    applyJPushAuthority(NotificationSettingsIOS(
      sound: true,
      alert: true,
      badge: true));

}
```

#### setJPushBadge

- 设置应用 badge 值，该方法还会同步 JPush 服务器的的 badge 值，JPush 服务器的 badge 值用于推送 badge 自动 +1 时会用到。

```dart

void fun(){

    setJPushBadge(66).then((bool? status) {});

}
```

### getJPushLaunchAppNotification

- 获取 iOS 点击推送启动应用的那条通知。

```dart

void fun(){

    getJPushLaunchAppNotification().then((Map<dynamic, dynamic>? map) {});

}
```

