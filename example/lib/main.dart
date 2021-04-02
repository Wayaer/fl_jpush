import 'package:flutter/material.dart';
import 'package:fl_jpush/fl_jpush.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 初始化
  setupWithJPush(
      iosKey: 'AppKey', //你自己应用的 AppKey
      production: false,
      channel: 'channel',
      debug: false);

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

    applyPushAuthorityWithJPush(
        const NotificationSettingsIOS(sound: true, alert: true, badge: true));

    getRegistrationIDWithJPush.then((String rid) {
      print('get registration id : $rid');
      text = 'getRegistrationID: $rid';
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
            child: Text(text ?? 'Unknown'),
            height: 80),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          _Button(
              title: '发本地推送',
              onPressed: () async {
                // 三秒后出发本地推送

                final LocalNotification localNotification = LocalNotification(
                    id: notificationID,
                    title: 'test',
                    buildId: 1,
                    content: 'LocalMessage',
                    fireTime: DateTime.now().add(const Duration(seconds: 1)),
                    subtitle: 'LocalMessage test',
                    badge: 5,
                    extra: <String, String>{'LocalMessage': 'test'});
                final LocalNotification res =
                    await sendLocalNotificationWithJPush(localNotification);
                if (res == null) return;
                text = res.toMap.toString();
                setState(() {});
              }),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          _Button(
              title: 'setTags',
              onPressed: () async {
                final TagResultModel map =
                    await setTagsWithJPush(<String>['test1', 'test2']);
                if (map == null) return;
                text = 'set tags success: ${map.toMap}}]';
                setState(() {});
              }),
          _Button(
              title: 'addTags',
              onPressed: () async {
                final TagResultModel map =
                    await addTagsWithJPush(<String>['test3', 'test4']);
                text = 'addTags success: ${map.toMap}}';
                setState(() {});
              }),
          _Button(
              title: 'deleteTags',
              onPressed: () async {
                final TagResultModel map =
                    await deleteTagsWithJPush(<String>['test1', 'test2']);
                text = 'deleteTags success: ${map.toMap}}';
                setState(() {});
              }),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          _Button(
              title: 'validTag',
              onPressed: () async {
                final TagResultModel map = await validTagWithJPush('test1');
                if (map == null) return;
                text = 'valid tags success: ${map.toMap}}]';
                setState(() {});
              }),
          _Button(
              title: 'getAllTags',
              onPressed: () async {
                final TagResultModel map = await getAllTagsWithJPush;
                text = 'getAllTags success: ${map.toMap}';
                setState(() {});
              }),
          _Button(
              title: 'cleanTags',
              onPressed: () async {
                final TagResultModel map = await cleanTagsWithJPush;
                text = 'cleanTags success: ${map.toMap}}';
                setState(() {});
              }),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          _Button(
              title: 'setAlias',
              onPressed: () async {
                final AliasResultModel map = await setAliasWithJPush('alias1');
                text = 'setAlias success: ${map.toMap}';
                setState(() {});
              }),
          _Button(
              title: 'getAlias',
              onPressed: () async {
                final AliasResultModel map = await getAliasWithJPush;
                text = 'getAlias success: ${map.toMap}';
                setState(() {});
              }),
          _Button(
              title: 'deleteAlias',
              onPressed: () async {
                final AliasResultModel map = await deleteAliasWithJPush;
                text = 'deleteAlias success: ${map.toMap}';
                setState(() {});
              }),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          _Button(
              title: 'stopPush',
              onPressed: () async {
                final bool status = await stopPushWithJPush;
                text = 'stopPush success: $status';
                setState(() {});
              }),
          _Button(
              title: 'resumePush',
              onPressed: () async {
                final bool status = await resumePushWithJPush;
                text = 'resumePush success: $status';
                setState(() {});
              }),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          _Button(
              title: 'clearAllNotifications',
              onPressed: () async {
                final bool data = await clearAllNotificationsWithJPush;
                text = 'clearAllNotifications success: $data';
                setState(() {});
              }),
          _Button(
              title: 'clearNotification',
              onPressed: () async {
                if (notificationID == null) return;
                final bool data =
                    await clearNotificationWithJPush(notificationID);
                text = 'clearNotification success: $data';
                setState(() {});
              }),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          _Button(
              title: 'setBadge 66',
              onPressed: () async {
                final bool map = await setBadgeWithJPush(66);
                if (map == null) return;
                text = 'setBadge success: $map';
                setState(() {});
              }),
          _Button(
              title: 'setBadge 0',
              onPressed: () async {
                final bool map = await setBadgeWithJPush(0);
                if (map == null) return;
                text = 'setBadge 0 success: $map';
                setState(() {});
              }),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          _Button(
              title: '打开系统设置',
              onPressed: () {
                openSettingsForNotificationWithJPush;
              }),
          _Button(
              title: '通知授权是否打开',
              onPressed: () {
                isNotificationEnabledWithJPush.then((bool value) {
                  text = '通知授权是否打开: $value';
                  setState(() {});
                });
              }),
        ]),
        const Text('仅支持 IOS'),
        _Button(
            title: 'getLaunchAppNotification',
            onPressed: () {
              getLaunchAppNotificationWithJPush
                  .then((Map<dynamic, dynamic> map) {
                print('getLaunchAppNotification:$map');
                text = 'getLaunchAppNotification success: $map';
                setState(() {});
              });
            }),
        const Text('仅支持 Android'),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          _Button(
              title: 'Push 是否已经被停止',
              onPressed: () {
                isPushStoppedJPush.then((bool value) {
                  text = 'Push Service 是否已经被停止: $value';
                  setState(() {});
                });
              }),
          _Button(
              title: 'getUDID',
              onPressed: () async {
                final String id = await getUdID;
                if (id == null) return;
                text = 'getUDID success: $id';
                setState(() {});
              }),
        ]),
      ])),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({@required this.onPressed, @required this.title});

  final VoidCallback onPressed;
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(6.0),
      child: ElevatedButton(onPressed: onPressed, child: Text(title)));
}
