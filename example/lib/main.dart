import 'package:fl_jpush/fl_jpush.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, title: '极光推送', home: HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
      debugPrint('初始化成功：$value');
      addEventHandler();
      FlJPush()
          .applyAuthorityWithIOS(const NotificationSettingsIOS(
              sound: true, alert: true, badge: true))
          .then((value) {
        debugPrint('请求通知 $value');
      });
    });
  }

  Future<void> addEventHandler() async {
    FlJPush().addEventHandler(onReceiveNotification: (JPushMessage? message) {
      debugPrint('onReceiveNotification: ${message?.toMap}');
      text = 'onReceiveNotification: ${message?.toMap}';
      setState(() {});
    }, onOpenNotification: (JPushMessage? message) {
      debugPrint('onOpenNotification: ${message?.toMap}');
      text = 'onOpenNotification: ${message?.toMap}';
      setState(() {});
    }, onReceiveMessage: (JPushMessage? message) {
      debugPrint('onReceiveMessage: ${message?.toMap}');
      text = 'onReceiveMessage: ${message?.toMap}';
      setState(() {});
    }, onReceiveNotificationAuthorization: (bool? state) {
      debugPrint('onReceiveNotificationAuthorization: $state');
      text = 'onReceiveNotificationAuthorization: $state';
      setState(() {});
    });
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
                    FlJPush().getRegistrationID().then((String? rid) {
                      debugPrint('get registration id : $rid');
                      text = 'getRegistrationID: $rid';
                      setState(() {});
                    });
                  }),
              ElevatedText(
                  title: '发本地推送',
                  onPressed: () async {
                    notificationID = DateTime.now().millisecondsSinceEpoch;
                    final LocalNotification localNotification =
                        LocalNotification(
                            id: notificationID,
                            title: 'test',
                            content: 'LocalMessage',
                            fireTime:
                                DateTime.now().add(const Duration(seconds: 5)),
                            badge: 5);
                    final LocalNotification? res = await FlJPush()
                        .sendLocalNotification(localNotification);
                    if (res == null) return;
                    text = res.toMap.toString();
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'setTags',
                  onPressed: () async {
                    final TagResultModel? map =
                        await FlJPush().setTags(<String>['test1', 'test2']);
                    if (map == null) return;
                    text = 'set tags success: ${map.toMap}}]';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'addTags',
                  onPressed: () async {
                    final TagResultModel? map =
                        await FlJPush().addTags(<String>['test3', 'test4']);
                    text = 'addTags success: ${map?.toMap}}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'deleteTags',
                  onPressed: () async {
                    final TagResultModel? map =
                        await FlJPush().deleteTags(<String>['test1', 'test2']);
                    text = 'deleteTags success: ${map?.toMap}}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'validTag',
                  onPressed: () async {
                    final TagResultModel? map =
                        await FlJPush().validTag('test1');
                    if (map == null) return;
                    text = 'valid tags success: ${map.toMap}}]';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'getAllTags',
                  onPressed: () async {
                    final TagResultModel? map = await FlJPush().getAllTags();
                    text = 'getAllTags success: ${map?.toMap}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'cleanTags',
                  onPressed: () async {
                    final TagResultModel? map = await FlJPush().cleanTags();
                    text = 'cleanTags success: ${map?.toMap}}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'setAlias',
                  onPressed: () async {
                    final AliasResultModel? map =
                        await FlJPush().setAlias('alias1');
                    text = 'setAlias success: ${map?.toMap}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'getAlias',
                  onPressed: () async {
                    final AliasResultModel? map = await FlJPush().getAlias();
                    text = 'getAlias success: ${map?.toMap}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'deleteAlias',
                  onPressed: () async {
                    final AliasResultModel? map = await FlJPush().deleteAlias();
                    text = 'deleteAlias success: ${map?.toMap}';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'stopPush',
                  onPressed: () async {
                    final bool status = await FlJPush().stop();
                    text = 'stopPush success: $status';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'resumePush',
                  onPressed: () async {
                    final bool status = await FlJPush().resume();
                    text = 'resumePush success: $status';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'clearNotification',
                  onPressed: () async {
                    final bool data = await FlJPush()
                        .clearNotification(notificationId: notificationID);
                    text = 'clearNotification success: $data';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'setBadge 66',
                  onPressed: () async {
                    final bool map = await FlJPush().setBadge(66);
                    text = 'setBadge success: $map';
                    setState(() {});
                  }),
              ElevatedText(
                  title: 'setBadge 0',
                  onPressed: () async {
                    final bool map = await FlJPush().setBadge(0);
                    text = 'setBadge 0 success: $map';
                    setState(() {});
                  }),
              ElevatedText(
                  title: '打开系统设置',
                  onPressed: () {
                    FlJPush().openSettingsForNotification();
                  }),
              ElevatedText(
                  title: '通知授权是否打开',
                  onPressed: () {
                    FlJPush().isNotificationEnabled().then((bool? value) {
                      text = '通知授权是否打开: $value';
                      setState(() {});
                    });
                  }),
            ]),
        const Text('仅支持 IOS'),
        ElevatedText(
            title: 'getLaunchAppNotification',
            onPressed: () {
              FlJPush()
                  .getLaunchAppNotificationWithIOS()
                  .then((Map<dynamic, dynamic>? map) {
                debugPrint('getLaunchAppNotification:$map');
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
                    FlJPush().isPushStopped().then((bool? value) {
                      text = 'Push Service 是否已经被停止: $value';
                      setState(() {});
                    });
                  }),
              ElevatedText(
                  title: 'getAndroidUdID',
                  onPressed: () async {
                    final String? id = await FlJPush().getUDIDWithAndroid();
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
  final VoidCallback onPressed;
  final String title;

  const ElevatedText({Key? key, required this.onPressed, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onPressed, child: Text(title));
}
