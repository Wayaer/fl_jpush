part of 'fl_jpush.dart';

typedef JPushEventHandler = void Function(JPushMessage message);

/// jPush event handler
class FlJPushEventHandler {
  FlJPushEventHandler({this.onOpenNotification, this.onReceiveMessage});

  /// 点击通知栏消息回调
  final JPushEventHandler? onOpenNotification;

  /// 接收消息
  final JPushEventHandler? onReceiveMessage;
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
      {this.onReceiveNotification,
      this.onReceiveNotificationAuthorization,
      this.onOpenSettingsForNotification});

  /// 接收普通消息
  final JPushEventHandler? onReceiveNotification;

  /// ios 获取消息认证 回调
  final JPushNotificationAuthorization? onReceiveNotificationAuthorization;

  /// openSettingsForNotification
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
        mutableContent = aps['mutableContent'] as int?;
        notificationAuthorization = aps['notificationAuthorization'] as bool?;
      }
      msgID = json['_j_msgid']?.toString();
      notificationID = json['_j_uid'] as int?;
      extras = json;
      (extras as Map<dynamic, dynamic>).removeWhere(
          (dynamic key, dynamic value) =>
              key == '_j_business' ||
              key == '_j_data_' ||
              key == 'aps' ||
              key == 'actionIdentifier' ||
              key == '_j_uid' ||
              key == '_j_msgid');
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
        'notificationAuthorization': notificationAuthorization,
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

class NotificationSettingsIOS {
  const NotificationSettingsIOS({
    this.sound = true,
    this.alert = true,
    this.badge = true,
  });

  final bool sound;
  final bool alert;
  final bool badge;

  Map<String, dynamic> toMap() =>
      {'sound': sound, 'alert': alert, 'badge': badge};
}

class LocalNotification {
  const LocalNotification(
      {required this.id,
      required this.title,
      required this.content,
      required this.fireTime,
      this.buildId = 1,
      this.extra = const {},
      this.badge,
      this.sound = 'default',
      this.subtitle = ''});

  /// 通知样式：1 为基础样式，2 为自定义样式（需先调用 `setStyleCustom` 设置自定义样式）
  final int buildId;

  /// 通知 id, 可用于取消通知
  final int id;

  /// 通知标题
  final String title;

  /// 通知内容
  final String content;

  /// extra 字段
  final Map<String, String> extra;

  /// 通知触发时间（毫秒）
  final DateTime fireTime;

  /// 本地推送触发后应用角标值
  final int? badge;

  /// 指定推送的音频文件 仅支持ios
  final String? sound;

  /// 子标题
  final String? subtitle;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'fireTime': fireTime.millisecondsSinceEpoch,
        'buildId': buildId,
        'extra': extra,
        'badge': badge,
        'sound': sound,
        'subtitle': subtitle
      };
}
