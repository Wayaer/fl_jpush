# JPush Flutter Plugin

### 配置

##### Android:

在 `/android/app/build.gradle` 中添加下列代码：

```groovy
android: {

  defaultConfig {
    applicationId '替换成自己应用 ID'

    manifestPlaceholders = [
        JPUSH_PKGNAME : applicationId,
        JPUSH_APPKEY : 'appkey', 
        JPUSH_CHANNEL : 'developer-default', 
    ]
  }    
}
```

##### iOS:
原生需要自己配置证书 等相关参数

### 使用

```dart
import 'package:fl_jpush/fl_jpush_dart';
```

### APIs

**注意** : 需要先调用 setupWithJPush 来初始化插件，才能保证其他功能正常工作。

#### addEventHandlerWithJPush

添加事件监听方法。

```dart

  Future<void> addEventHandlerWithJPush() async {
    addEventHandlerWithJPush(onReceiveNotification: (JPushMessage message) {
      print('onReceiveNotification: ${message.toMap}');
      text = 'onReceiveNotification: ${message.title}';
      setState(() {});
    }, onOpenNotification: (JPushMessage message) {
      print('onOpenNotification: ${message.toMap}');
      text = 'onOpenNotification: ${message.title}';
      setState(() {});
    }, onReceiveMessage: (JPushMessage message) {
      print('onReceiveMessage: ${message.toMap}');
      text = 'onReceiveMessage: ${message.title}';
      setState(() {});
    }, onReceiveNotificationAuthorization: (JPushMessage message) {
      print('onReceiveNotificationAuthorization: ${message.toMap}');
      text = 'onReceiveNotificationAuthorization: ${message.title}';
      setState(() {});
    });

  }

```

#### setupWithJPush

添加初始化方法，调用 setupWithJPush 方法会执行两个操作：


**注意：**  android 端支持在 setupWithJPush 方法中动态设置 channel，动态设置的 channel 优先级比 manifestPlaceholders 中的 JPUSH_CHANNEL 优先级要高。
```dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 初始化
  setupWithJPush(
      iosKey: 'AppKey', //你自己应用的 AppKey
      production: false,
      channel: 'channel',
      debug: false);

  runApp(MaterialApp());
}
```

#### getRegistrationID

获取 registrationId，这个 JPush 运行通过 registrationId 来进行推送.

```dart
 void getRegistrationID (){
   getRegistrationIDWithJPush.then((String rid) {
      print('get registration id : $rid');
    });
  }
```

#### stopPushWithJPush

停止推送功能，调用该方法将不会接收到通知。

```dart

stopPushWithJPush
```

#### resumePushWithJPush

调用 stopPushWithJPush 后，可以通过 resumePushWithJPush 方法恢复推送。

```dart

resumePushWithJPush;
```

#### setAliasWithJPush

设置别名，极光后台可以通过别名来推送，一个 App 应用只有一个别名，一般用来存储用户 id。

```dart

setAliasWithJPush('your alias').then((AliasResultModel model) { });
```

#### deleteAliasWithJPush

删除 alias。

```dart

deleteAliasWithJPush.then((AliasResultModel model) {})
```


#### getAliasWithJPush

获取 alias.

```dart

getAliasWithJPush.then((AliasResultModel model) {})
```

#### addTagsWithJPush

在原来的 Tags 列表上添加指定 tags。

```dart

addTagsWithJPush(['tag1','tag2']).then((TagResultModel model) {});
```

####  deleteTagsWithJPush

在原来的 Tags 列表上删除指定 tags。

```dart

deleteTagsWithJPush(['tag1','tag2']).then((TagResultModel model) {});
```

#### setTagsWithJPush

重置 tags。

```dart

setTagsWithJPush(['tag1','tag2']).then((TagResultModel model) {});
```

#### validTagWithJPush

验证tag是否绑定。

```dart

validTagWithJPush('tag1').then((TagResultModel model) {});
```

#### cleanTagsWithJPush

清空所有 tags

```dart

cleanTagsWithJPush.then((TagResultModel model) {});
```

#### getAllTagsWithJPush

获取当前 tags 列表。

```dart

getAllTagsWithJPush.then((TagResultModel model) {});

```

#### sendLocalNotificationWithJPush

指定触发时间，添加本地推送通知。

```dart
// 延时 3 秒后触发本地通知。

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
sendLocalNotificationWithJPush(localNotification).then((localNotification) {});
```

#### clearNotificationWithJPush

清空通知栏上某个通知

```dart

bool status = await clearNotificationWithJPush(notificationId);
```


#### clearAllNotificationsWithJPush

清楚通知栏上所有通知。

```dart

clearAllNotificationsWithJPush;
```


#### isNotificationEnabledWithJPush

检测通知授权状态是否打开

```dart

bool status = await isNotificationEnabledWithJPush;
```

**Android Only **


#### isPushStoppedJPush

 Push Service 是否已经被停止

```dart

bool status = await isPushStoppedJPush;
```

#### getUdID

获取UDID

```dart

String udid = await getUdID;
```


**iOS Only **

#### applyPushAuthorityWithJPush

申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。

**注意： iOS10+ 可以通过该方法来设置推送是否前台展示，是否触发声音，是否设置应用角标 badge**

```dart

applyPushAuthorityWithJPush(NotificationSettingsIOS(
      sound: true,
      alert: true,
      badge: true));
```

#### setBadgeWithJPush

设置应用 badge 值，该方法还会同步 JPush 服务器的的 badge 值，JPush 服务器的 badge 值用于推送 badge 自动 +1 时会用到。

```dart

setBadgeWithJPush(66).then((bool status) {});
```

### getLaunchAppNotificationWithJPush

获取 iOS 点击推送启动应用的那条通知。

```dart

getLaunchAppNotificationWithJPush().then((Map<dynamic, dynamic> map) {});
```

