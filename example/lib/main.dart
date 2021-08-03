import 'package:fl_jpush/fl_jpush.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 初始化
  final bool key = await FlJPush.instance.setup(
      iosKey: '3af087cca42c9f95df54ab89', //你自己应用的 AppKey
      production: false,
      channel: 'channel',
      debug: false);
  print('初始化成功：$key');
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false, title: '极光推送', home: HomePage()));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = 'Unknown';
  int notificationID = 222;

  @override
  void initState() {
    super.initState();
    addEventHandler();
  }

  Future<void> addEventHandler() async {
    FlJPush.instance.addEventHandler(
        onReceiveNotification: (JPushMessage? message) {
      print('onReceiveNotification: ${message?.toMap}');
      text = 'onReceiveNotification: ${message?.alert}';
      setState(() {});
    }, onOpenNotification: (JPushMessage? message) {
      print('onOpenNotification: ${message?.toMap}');
      text = 'onOpenNotification: ${message?.alert}';
      setState(() {});
    }, onReceiveMessage: (JPushMessage? message) {
      print('onReceiveMessage: ${message?.toMap}');
      text = 'onReceiveMessage: ${message?.alert}';
      setState(() {});
    }, onReceiveNotificationAuthorization: (bool? state) {
      print('onReceiveNotificationAuthorization: $state');
      text = 'onReceiveNotificationAuthorization: $state';
      setState(() {});
    });

    FlJPush.instance.applyAuthorityWithIOS(
        const NotificationSettingsIOS(sound: true, alert: true, badge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('极光推送 Flutter')),
      body: SingleChildScrollView(
          child: Column(children: <Widget>[
        Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
            child: Text(text),
            height: 100),
        Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 10,
            spacing: 10,
            children: <Widget>[
              ElevatedText(
                  title: 'getRegistrationID',
                  onPressed: () {
                    FlJPush.instance.getRegistrationID().then((String? rid) {
                      print('get registration id : $rid');
                      text = 'getRegistrationID: $rid';
                      setState(() {});
                    });
                  }),
              ElevatedText(
                  title: '发本地推送',
                  onPressed: () async {
                    final LocalNotification localNotification =
                        LocalNotification(
                            id: notificationID,
                            title: 'test',
                            buildId: 1,
                            content: 'LocalMessage',
                            fireTime:
                                DateTime.now().add(const Duration(seconds: 1)),
                            subtitle: 'LocalMessage test',
                            badge: 5,
                            extra: <String, String>{'LocalMessage': 'test'});
                    final LocalNotification? res = await FlJPush.instance
                        .sendLocalNotification(localNotification);
                    if (res == null) return;
                    text = res.toMap.toString();
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'setTags',
                  onPressed: () async {
                    final TagResultModel? map = await FlJPush.instance
                        .setTags(<String>['test1', 'test2']);
                    if (map == null) return;
                    text = 'set tags success: ${map.toMap}}]';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'addTags',
                  onPressed: () async {
                    final TagResultModel? map = await FlJPush.instance
                        .addTags(<String>['test3', 'test4']);
                    text = 'addTags success: ${map?.toMap}}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'deleteTags',
                  onPressed: () async {
                    final TagResultModel? map = await FlJPush.instance
                        .deleteTags(<String>['test1', 'test2']);
                    text = 'deleteTags success: ${map?.toMap}}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'validTag',
                  onPressed: () async {
                    final TagResultModel? map =
                        await FlJPush.instance.validTag('test1');
                    if (map == null) return;
                    text = 'valid tags success: ${map.toMap}}]';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'getAllTags',
                  onPressed: () async {
                    final TagResultModel? map =
                        await FlJPush.instance.getAllTags();
                    text = 'getAllTags success: ${map?.toMap}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'cleanTags',
                  onPressed: () async {
                    final TagResultModel? map =
                        await FlJPush.instance.cleanTags();
                    text = 'cleanTags success: ${map?.toMap}}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'setAlias',
                  onPressed: () async {
                    final AliasResultModel? map =
                        await FlJPush.instance.setAlias('alias1');
                    text = 'setAlias success: ${map?.toMap}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'getAlias',
                  onPressed: () async {
                    final AliasResultModel? map =
                        await FlJPush.instance.getAlias();
                    text = 'getAlias success: ${map?.toMap}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'deleteAlias',
                  onPressed: () async {
                    final AliasResultModel? map =
                        await FlJPush.instance.deleteAlias();
                    text = 'deleteAlias success: ${map?.toMap}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'stopPush',
                  onPressed: () async {
                    final bool status = await FlJPush.instance.stop();
                    text = 'stopPush success: $status';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'resumePush',
                  onPressed: () async {
                    final bool status = await FlJPush.instance.resume();
                    text = 'resumePush success: $status';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'clearAllNotifications',
                  onPressed: () async {
                    final bool data =
                        await FlJPush.instance.clearAllNotifications();
                    text = 'clearAllNotifications success: $data';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'clearNotification',
                  onPressed: () async {
                    final bool data = await FlJPush.instance
                        .clearNotification(notificationID);
                    text = 'clearNotification success: $data';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'setBadge 66',
                  onPressed: () async {
                    final bool map = await FlJPush.instance.setBadge(66);
                    text = 'setBadge success: $map';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'setBadge 0',
                  onPressed: () async {
                    final bool map = await FlJPush.instance.setBadge(0);
                    text = 'setBadge 0 success: $map';
                    setState(() {});
                  }),
              ElevatedText(
                  title: '打开系统设置',
                  onPressed: () {
                    FlJPush.instance.openSettingsForNotification();
                  }),
              ElevatedText(
                  title: '通知授权是否打开',
                  onPressed: () {
                    FlJPush.instance
                        .isNotificationEnabled()
                        .then((bool? value) {
                      text = '通知授权是否打开: $value';
                      setState(() {});
                    });
                  }),
            ]),
        const Text('仅支持 IOS'),
        ElevatedText(
            title: 'getLaunchAppNotification',
            onPressed: () {
              FlJPush.instance
                  .getLaunchAppNotificationWithIOS()
                  .then((Map<dynamic, dynamic>? map) {
                print('getLaunchAppNotification:$map');
                text = 'getLaunchAppNotification success: $map';
                setState(() {});
              });
            }),
        const Text('仅支持 Android'),
        Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 10,
            spacing: 10,
            children: <Widget>[
              ElevatedText(
                  title: 'Push 是否已经被停止',
                  onPressed: () {
                    FlJPush.instance.isPushStopped().then((bool? value) {
                      text = 'Push Service 是否已经被停止: $value';
                      setState(() {});
                    });
                  }),
              ElevatedText(
                  title: 'getAndroidUdID',
                  onPressed: () async {
                    final String? id =
                        await FlJPush.instance.getUDIDWithAndroid();
                    if (id == null) return;
                    text = 'getAndroidJPushUdID success: $id';
                    setState(() {});
                  }),
            ]),
        const SizedBox(height: 100),
      ])),
    );
  }
}

class ElevatedText extends StatelessWidget {
  const ElevatedText({required this.onPressed, required this.title});

  final VoidCallback onPressed;
  final String title;

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onPressed, child: Text(title));
}
