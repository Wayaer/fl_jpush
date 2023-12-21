part of 'fl_jpush.dart';

typedef JPushEventHandler = void Function(JPushMessage message);

/// jPush event handler
class FlJPushEventHandler {
  FlJPushEventHandler({this.onOpenNotification, this.onReceiveNotification});

  /// 点击通知栏消息回调
  final JPushEventHandler? onOpenNotification;

  /// 接收普通消息
  final JPushEventHandler? onReceiveNotification;
}

class FlJPushCmdMessage {
  FlJPushCmdMessage(Map<dynamic, dynamic> map)
      : cmd = map['cmd'] as int,
        errorCode = map['errorCode'] as int,
        msg = map['msg'] as String;

  final int cmd;
  final int errorCode;
  final String msg;

  Map<String, dynamic> toMap() =>
      {'cmd': cmd, 'errorCode': errorCode, 'msg': msg};
}

typedef JPushAndroidOnConnected = void Function(bool isConnected);

typedef JPushAndroidOnCommandResult = void Function(FlJPushCmdMessage message);

typedef JPushAndroidOnMultiActionClicked = void Function(String? action);

/// android event handler
class FlJPushAndroidEventHandler {
  FlJPushAndroidEventHandler({
    this.onConnected,
    this.onCommandResult,
    this.onNotifyMessageDismiss,
    this.onMultiActionClicked,
    this.onMessage,
  });

  /// onConnected
  final JPushAndroidOnConnected? onConnected;

  /// onCommandResult
  final JPushAndroidOnCommandResult? onCommandResult;

  /// onNotifyMessageDismiss
  final JPushEventHandler? onNotifyMessageDismiss;

  /// onMultiActionClicked
  final JPushAndroidOnMultiActionClicked? onMultiActionClicked;

  /// onMessage
  final JPushEventHandler? onMessage;
}

typedef JPushNotificationAuthorization = void Function(bool state);
typedef JPushOnOpenSettingsForNotification = void Function(dynamic data);

/// ios event handler
class FlJPushIOSEventHandler {
  FlJPushIOSEventHandler(
      {this.onReceiveMessage,
      this.onReceiveNotificationAuthorization,
      this.onOpenSettingsForNotification});

  /// 接收自定义消息
  final JPushEventHandler? onReceiveMessage;

  /// ios 获取消息认证 回调
  final JPushNotificationAuthorization? onReceiveNotificationAuthorization;

  /// openSettingsForNotification
  /// 从应用外部通知界面进入应用是指 左滑通知->管理->在“某 App”中配置->进入应用 。
  /// 从通知设置界面进入应用是指 系统设置->对应应用->“某 App”的通知设置
  /// 需要先在授权的时候增加这个选项 JPAuthorizationOptionProvidesAppNotificationSettings
  final JPushOnOpenSettingsForNotification? onOpenSettingsForNotification;
}

/// 统一android ios 回传数据解析
class JPushMessage {
  JPushMessage.fromMap(Map<dynamic, dynamic> json) {
    if (json.containsKey('aps')) {
      final Map<dynamic, dynamic>? aps = json['aps'] as Map<dynamic, dynamic>?;
      if (aps != null) {
        alert = aps['alert'] as dynamic;
        badge = aps['badge'] as int?;
        sound = aps['sound'] as String?;
        mutableContent =
            aps['mutableContent'] ?? aps['mutable-content'] as int?;
        notificationAuthorization = aps['notificationAuthorization'] as bool?;
      }
      msgID = json['_j_msgid']?.toString();
      notificationID = json['_j_uid'] as int?;
      extras = json;
    } else {
      message = json['message'] as String?;
      alert = json['alert'] as dynamic;
      final Map<dynamic, dynamic>? extras =
          json['extras'] as Map<dynamic, dynamic>?;
      if (extras != null) {
        msgID = extras['cn.jpush.android.MSG_ID'] as String?;
        notificationID = extras['cn.jpush.android.NOTIFICATION_ID'] as int?;
        this.extras = extras['cn.jpush.android.EXTRA'];
      }
    }
    original = json;
    title = json['title'] as String?;
  }

  /// 原始数据 原生返回未解析的数据
  /// 其他参数 均由 [original] 解析所得
  Map<dynamic, dynamic>? original;

  String? msgID;
  int? notificationID;

  /// 一般情况下使用的数据
  dynamic alert;

  /// 一般情况下使用的额外数据
  dynamic extras;

  String? title;

  /// only android
  String? message;

  /// only ios
  /// 监测通知授权状态返回结果
  bool? notificationAuthorization;
  String? sound;
  String? subtitle;
  int? badge;
  int? mutableContent;

  Map<String, dynamic> toMap() => {
        'alert': alert,
        'extras': extras,
        'message': message,
        'title': title,
        'msgID': msgID,
        'notificationID': notificationID,
        'subtitle': subtitle,
        'sound': sound,
        'badge': badge,
        'mutableContent': mutableContent,
        'original': original,
      };
}

class TagResultModel {
  TagResultModel({
    required this.code,
    required this.tags,
    this.isBind,
  });

  TagResultModel.fromMap(Map<dynamic, dynamic> json, [String? tag]) {
    code = json['code'] as int;
    isBind = json['isBind'] as bool?;
    tags = json['tags'] == null
        ? tag == null
            ? <String>[]
            : <String>[tag]
        : (json['tags'] as List<dynamic>)
            .map((dynamic e) => e as String)
            .toList();
  }

  late List<String> tags;

  /// jPush状态🐴
  late int code;

  /// 校验tag 是否绑定
  bool? isBind;

  Map<String, dynamic> toMap() =>
      {'tags': tags, 'code': code, 'isBind': isBind};
}

class AliasResultModel {
  AliasResultModel({
    required this.code,
    this.alias,
  });

  AliasResultModel.fromMap(Map<dynamic, dynamic> json) {
    code = json['code'] as int;
    alias = json['alias'] as String?;
    if (alias != null && alias!.isEmpty) alias = null;
  }

  String? alias;

  /// jPush状态🐴
  late int code;

  Map<String, dynamic> toMap() => {'alias': alias, 'code': code};
}

class NotificationSettingsWithIOS {
  const NotificationSettingsWithIOS({
    this.sound = true,
    this.alert = true,
    this.badge = true,
    this.providesAppNotificationSettings = true,
    this.announcement = true,
    this.provisional = true,
    this.carPlay = true,
  });

  /// sound
  final bool sound;

  /// alert
  final bool alert;

  /// badge
  final bool badge;

  /// announcement
  final bool announcement;

  /// provisional
  final bool provisional;

  /// carPlay
  final bool carPlay;

  /// providesAppNotificationSettings
  /// 从应用外部通知界面进入应用是指 左滑通知->管理->在“某 App”中配置->进入应用 。
  /// 从通知设置界面进入应用是指 系统设置->对应应用->“某 App”的通知设置
  /// 需要先在授权的时候增加这个选项 JPAuthorizationOptionProvidesAppNotificationSettings
  final bool providesAppNotificationSettings;

  Map<String, dynamic> toMap() => {
        'sound': sound,
        'alert': alert,
        'badge': badge,
        'announcement': announcement,
        'provisional': provisional,
        'carPlay': carPlay,
        'providesAppNotificationSettings': providesAppNotificationSettings
      };
}

/// android 本地推送消息设置
class LocalNotificationWithAndroid extends LocalNotification {
  LocalNotificationWithAndroid({
    required super.id,
    this.buildId = 1,
  });

  /// 通知样式：1 为基础样式，2 为自定义样式（需先调用 `setStyleCustom` 设置自定义样式）
  final int buildId;

  @override
  Map<String, dynamic> toMap() => {...super.toMap(), 'buildId': buildId};
}

/// ios 本地推送消息设置
class LocalNotificationWithIOS extends LocalNotification {
  LocalNotificationWithIOS(
      {required super.id, this.sound = 'default', this.subtitle = 'subtitle'});

  /// 指定推送的音频文件 默认为 'default'
  final String? sound;

  /// 子标题
  final String subtitle;

  @override
  Map<String, dynamic> toMap() =>
      {...super.toMap(), 'sound': sound, 'subtitle': subtitle};
}

/// 基础信息设置
class LocalNotification {
  const LocalNotification({
    required this.id,
    this.title = 'title',
    this.content = 'content',
    this.fireTime = 1,
    this.extra = const {},
    this.badge,
  }) : assert(fireTime > 0);

  /// 通知 id, 可用于取消通知
  final int id;

  /// 通知标题
  final String title;

  /// 通知内容
  final String content;

  /// extra 字段
  final Map<String, String> extra;

  /// 通知触发时间（秒）
  final int fireTime;

  /// 本地推送触发后应用角标值
  final int? badge;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'fireTime': fireTime,
        'extra': extra,
        'badge': badge,
      };

  LocalNotificationWithAndroid toAndroid() =>
      LocalNotificationWithAndroid(id: id);

  LocalNotificationWithIOS toIOS() => LocalNotificationWithIOS(id: id);
}
