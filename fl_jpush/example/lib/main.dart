import 'package:fl_jpush/fl_jpush.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';

void log(dynamic msg) => debugPrint(msg.toString());

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '极光推送',
      home: Scaffold(
          appBar: AppBar(title: const Text('极光推送 Flutter')),
          body: const SingleChildScrollView(child: HomePage()))));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = 'Unknown';
  int notificationID = 222;

  @override
  void initState() {
    super.initState();

    /// 初始化
    FlJPush()
        .setup(
            appKey: '3af087cca42c9f95df54ab89',
            //你自己应用的 AppKey
            production: true,
            channel: 'channel',
            debug: true)
        .then((bool value) {
      log('初始化成功：$value');
      addEventHandler();
      if (isIOS) {
        FlJPush()
            .applyAuthorityWithIOS(const NotificationSettingsWithIOS())
            .then((value) {
          log('请求通知 $value');
        });
      }
      if (isAndroid) {
        FlJPush().requestPermission();
      }
    });
  }

  Future<void> addEventHandler() async {
    FlJPush().addEventHandler(
        eventHandler:
            FlJPushEventHandler(onOpenNotification: (JPushMessage message) {
          /// 点击通知栏消息回调
          log('onOpenNotification: ${message.toMap()}');
          text = 'onOpenNotification: ${message.toMap()}';
          setState(() {});
        }, onReceiveNotification: (JPushMessage message) {
          /// 接收普通消息
          log('onReceiveNotification: ${message.toMap()}');
          text = 'onReceiveNotification: ${message.toMap()}';
          setState(() {});
        }, onReceiveMessage: (JPushMessage message) {
          /// 接收自定义消息
          log('onReceiveMessage: ${message.toMap()}');
          text = 'onReceiveMessage: ${message.toMap()}';
          setState(() {});
        }),
        androidEventHandler: FlJPushAndroidEventHandler(
            onCommandResult: (FlJPushCmdMessage message) {
          log('onCommandResult: ${message.toMap()}');
        }, onNotifyMessageDismiss: (JPushMessage message) {
          /// onNotifyMessageDismiss
          /// 清除通知回调
          /// 1.同时删除多条通知，可能不会多次触发清除通知的回调
          /// 2.只有用户手动清除才有回调，调接口清除不会有回调
          log('onNotifyMessageDismiss: ${message.toMap()}');
          text = 'onNotifyMessageDismiss: ${message.toMap()}';
          setState(() {});
        }, onNotificationSettingsCheck:
                (FlJPushNotificationSettingsCheck settingsCheck) {
          /// 通知开关状态回调
          /// 说明: sdk 内部检测通知开关状态的方法因系统差异，在少部分机型上可能存在兼容问题(判断不准确)。
          /// source 触发场景，0 为 sdk 启动，1 为检测到通知开关状态变更
          log('onNotificationSettingsCheck: ${settingsCheck.toMap()}');
          text = 'onNotificationSettingsCheck: ${settingsCheck.toMap()}';
          setState(() {});
        }),
        iosEventHandler: FlJPushIOSEventHandler(
            onReceiveNotificationAuthorization: (bool? state) {
          /// ios 申请通知权限 回调
          log('onReceiveNotificationAuthorization: $state');
          text = 'onReceiveNotificationAuthorization: $state';
          log("flutter: $text");
          setState(() {});
        }, onOpenSettingsForNotification: (data) {
          /// 从应用外部通知界面进入应用是指 左滑通知->管理->在“某 App”中配置->进入应用 。
          /// 从通知设置界面进入应用是指 系统设置->对应应用->“某 App”的通知设置
          /// 需要先在授权的时候增加这个选项 JPAuthorizationOptionProvidesAppNotificationSettings
          log('onOpenSettingsForNotification: $data');
          text = 'onOpenSettingsForNotification: $data';
          setState(() {});
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(10),
          height: 100,
          child: Text(text)),
      Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 10,
          spacing: 10,
          children: <Widget>[
            ElevatedText(
                text: 'getRegistrationID',
                onPressed: () {
                  FlJPush().getRegistrationID().then((String? rid) {
                    log('get registration id : $rid');
                    text = 'getRegistrationID: $rid';
                    setState(() {});
                  });
                }),
            ElevatedText(
                text: '发本地推送',
                onPressed: () async {
                  final localNotification = LocalNotification(
                      id: notificationID,
                      title: 'test',
                      content: 'flutter send LocalMessage',
                      fireTime: 2,
                      badge: 5);
                  final res = await FlJPush().sendLocalNotification(
                      android: localNotification.toAndroid(),
                      ios: localNotification.toIOS());
                  text = "$res";
                  setState(() {});
                }),
            ElevatedText(
                text: 'setTags',
                onPressed: () async {
                  final TagResultModel? map =
                      await FlJPush().setTags(<String>['test1', 'test2']);
                  if (map == null) return;
                  text = 'set tags success: ${map.toMap()}}]';
                  setState(() {});
                }),
            ElevatedText(
                text: 'addTags',
                onPressed: () async {
                  final TagResultModel? map =
                      await FlJPush().addTags(<String>['test3', 'test4']);
                  text = 'addTags success: ${map?.toMap()}}';
                  setState(() {});
                }),
            ElevatedText(
                text: 'deleteTags',
                onPressed: () async {
                  final TagResultModel? map =
                      await FlJPush().deleteTags(<String>['test1', 'test2']);
                  text = 'deleteTags success: ${map?.toMap()}}';
                  setState(() {});
                }),
            ElevatedText(
                text: 'validTag',
                onPressed: () async {
                  final TagResultModel? map = await FlJPush().validTag('test1');
                  if (map == null) return;
                  text = 'valid tags success: ${map.toMap()}}]';
                  setState(() {});
                }),
            ElevatedText(
                text: 'getAllTags',
                onPressed: () async {
                  final TagResultModel? map = await FlJPush().getAllTags();
                  text = 'getAllTags success: ${map?.toMap()}';
                  setState(() {});
                }),
            ElevatedText(
                text: 'cleanTags',
                onPressed: () async {
                  final TagResultModel? map = await FlJPush().cleanTags();
                  text = 'cleanTags success: ${map?.toMap()}}';
                  setState(() {});
                }),
            ElevatedText(
                text: 'setAlias',
                onPressed: () async {
                  final AliasResultModel? map =
                      await FlJPush().setAlias('alias1');
                  text = 'setAlias success: ${map?.toMap()}';
                  setState(() {});
                }),
            ElevatedText(
                text: 'getAlias',
                onPressed: () async {
                  final AliasResultModel? map = await FlJPush().getAlias();
                  text = 'getAlias success: ${map?.toMap()}';
                  setState(() {});
                }),
            ElevatedText(
                text: 'deleteAlias',
                onPressed: () async {
                  final AliasResultModel? map = await FlJPush().deleteAlias();
                  text = 'deleteAlias success: ${map?.toMap()}';
                  setState(() {});
                }),
            ElevatedText(
                text: 'stopPush',
                onPressed: () async {
                  final bool status = await FlJPush().stop();
                  text = 'stopPush success: $status';
                  setState(() {});
                }),
            ElevatedText(
                text: 'resumePush',
                onPressed: () async {
                  final bool status = await FlJPush().resume();
                  text = 'resumePush success: $status';
                  setState(() {});
                }),
            ElevatedText(
                text: 'clearNotification',
                onPressed: () async {
                  final bool data = await FlJPush()
                      .clearNotification(notificationId: notificationID);
                  text = 'clearNotification success: $data';
                  setState(() {});
                }),
            ElevatedText(
                text: 'setBadge 66',
                onPressed: () async {
                  final bool map = await FlJPush().setBadge(66);
                  text = 'setBadge success: $map';
                  setState(() {});
                }),
            ElevatedText(
                text: 'setBadge 0',
                onPressed: () async {
                  final bool map = await FlJPush().setBadge(0);
                  text = 'setBadge 0 success: $map';
                  setState(() {});
                }),
            ElevatedText(
                text: '打开系统设置',
                onPressed: () {
                  FlJPush().openSettingsForNotification();
                }),
            ElevatedText(
                text: '通知授权是否打开',
                onPressed: () {
                  FlJPush().isNotificationEnabled().then((bool? value) {
                    text = '通知授权是否打开: $value';
                    setState(() {});
                  });
                }),
          ]),
      if (isIOS)
        ElevatedText(
            text: 'getLaunchAppNotification',
            onPressed: () {
              FlJPush()
                  .getLaunchAppNotificationWithIOS()
                  .then((Map<dynamic, dynamic>? map) {
                log('getLaunchAppNotification:$map');
                text = 'getLaunchAppNotification success: $map';
                setState(() {});
              });
            }),
      if (isAndroid)
        Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 10,
            spacing: 10,
            children: <Widget>[
              ElevatedText(
                  text: 'Push 是否已经被停止',
                  onPressed: () {
                    FlJPush().isPushStopped().then((bool? value) {
                      text = 'Push Service 是否已经被停止: $value';
                      setState(() {});
                    });
                  }),
              ElevatedText(
                  text: 'getAndroidUdID',
                  onPressed: () async {
                    final String? id = await FlJPush().getUDIDWithAndroid();
                    if (id == null) return;
                    text = 'getAndroidJPushUdID success: $id';
                    setState(() {});
                  }),
            ]),
      const SizedBox(height: 100),
    ]);
  }
}

class ElevatedText extends ElevatedButton {
  ElevatedText({super.key, required super.onPressed, required String text})
      : super(child: Text(text));
}
