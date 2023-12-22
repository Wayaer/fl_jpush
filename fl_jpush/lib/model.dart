part of 'fl_jpush.dart';

typedef JPushEventHandler = void Function(JPushMessage message);

/// jPush event handler
class FlJPushEventHandler {
  FlJPushEventHandler(
      {this.onOpenNotification,
      this.onReceiveNotification,
      this.onReceiveMessage});

  /// 点击通知栏消息回调
  final JPushEventHandler? onOpenNotification;

  /// 接收普通消息
  final JPushEventHandler? onReceiveNotification;

  /// onMessage
  /// 自定义消息
  final JPushEventHandler? onReceiveMessage;
}

typedef JPushAndroidOnCommandResult = void Function(FlJPushCmdMessage message);

typedef JPushOnNotificationSettingsCheck = void Function(
    FlJPushNotificationSettingsCheck settingsCheck);

/// android event handler
class FlJPushAndroidEventHandler {
  FlJPushAndroidEventHandler({
    this.onCommandResult,
    this.onNotifyMessageDismiss,
    this.onNotificationSettingsCheck,
  });

  /// onCommandResult
  /// cmd	  | errorCode	| msg	                     | DESCRIPTION
  /// 0	    | 失败 code  | 失败信息	                 | 注册失败
  /// 1000	| 0	        | 错误信息		               | 自定义消息展示错误
  /// 2003	| 0 / 1  	  | not stop / stopped	     | isPushStopped 异步回调
  /// 2004	| 0 / 1	    | connected / not connect	 | getConnectionState 异步回调
  /// 2005	| 0	        | 对应 rid		               | getRegistrationID 异步回调
  /// 2006	| 0	        | set success		           | onResume 设置回调
  /// 2007	| 0	        | set success		           | onStop 设置回调
  /// 2008	| 0	        | success		               | 应用冷启动后，SDK 首次初始化成功的回调(只回调一次)
  /// 10000	| 0	        | 无		                   | 厂商 token 注册回调，通过 extra 可获取对应 platform 和 token 信息
  final JPushAndroidOnCommandResult? onCommandResult;

  /// onNotifyMessageDismiss
  /// 清除通知回调
  /// 1.同时删除多条通知，可能不会多次触发清除通知的回调
  /// 2.只有用户手动清除才有回调，调接口清除不会有回调
  final JPushEventHandler? onNotifyMessageDismiss;

  /// onNotificationSettingsCheck
  /// 通知开关状态回调
  /// 说明: sdk 内部检测通知开关状态的方法因系统差异，在少部分机型上可能存在兼容问题(判断不准确)。
  /// source 触发场景，0 为 sdk 启动，1 为检测到通知开关状态变更
  final JPushOnNotificationSettingsCheck? onNotificationSettingsCheck;
}

typedef JPushNotificationAuthorization = void Function(bool state);

typedef JPushOnOpenSettingsForNotification = void Function(JPushMessage data);

/// ios event handler
class FlJPushIOSEventHandler {
  FlJPushIOSEventHandler(
      {this.onReceiveNotificationAuthorization,
      this.onOpenSettingsForNotification});

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

class FlJPushNotificationSettingsCheck {
  FlJPushNotificationSettingsCheck(Map<dynamic, dynamic> map)
      : source = map['source'] as int,
        isOn = map['isOn'] as bool;

  /// 触发场景，0 为 sdk 启动，1 为检测到通知开关状态变更
  final int source;

  /// 通知开关状态
  final bool isOn;

  Map<String, dynamic> toMap() => {'source': source, 'isOn': isOn};
}
