import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

typedef JPushEventHandler = void Function(JPushMessage? event);

MethodChannel _channel = const MethodChannel('fl_jpush');

Future<void> setupJPush(
    {required String iosKey,
    bool production = false,
    String? channel = '',
    bool debug = false}) async {
  await _channel.invokeMethod<dynamic>('setup', <String, dynamic>{
    'appKey': iosKey,
    'channel': channel,
    'production': production,
    'debug': debug
  });
}

/// 初始化 JPush 必须先初始化才能执行其他操作(比如接收事件传递)
void addJPushEventHandler({
  /// 接收普通消息
  JPushEventHandler? onReceiveNotification,

  /// 点击通知栏消息回调
  JPushEventHandler? onOpenNotification,
  JPushEventHandler? onReceiveMessage,

  /// ios 消息认证
  JPushEventHandler? onReceiveNotificationAuthorization,
}) {
  _channel.setMethodCallHandler((MethodCall call) async {
    final Map<dynamic, dynamic>? map = call.arguments as Map<dynamic, dynamic>;
    JPushMessage? message;
    if (map != null) {
      if (Platform.isIOS) {
        final _IOSModel _iosModel = _IOSModel.fromJson(map);
        message = JPushMessage();
        message.title = _iosModel.aps?.alert?.title;
        message.body = _iosModel.aps?.alert?.body;
        message.subtitle = _iosModel.aps?.alert?.subtitle;
        message.extras = _iosModel.extras;
        message.badge = _iosModel.aps?.badge;
        message.sound = _iosModel.aps?.sound;
        message.notificationAuthorization = _iosModel.notificationAuthorization;
      } else {
        message = JPushMessage.fromMap(map);
      }
    }
    switch (call.method) {
      case 'onReceiveNotification':
        if (onReceiveNotification != null) onReceiveNotification(message);
        break;
      case 'onOpenNotification':
        if (onOpenNotification != null) onOpenNotification(message);
        break;
      case 'onReceiveMessage':
        if (onReceiveMessage != null) onReceiveMessage(message);
        break;
      case 'onReceiveNotificationAuthorization':
        if (onReceiveNotificationAuthorization != null)
          onReceiveNotificationAuthorization(message);
        break;
      default:
        throw UnsupportedError('Unrecognized Event');
    }
  });
}

/// iOS Only
/// 申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。
Future<void> applyJPushAuthority(
    [NotificationSettingsIOS iosSettings =
        const NotificationSettingsIOS()]) async {
  if (!Platform.isIOS) return;
  return await _channel.invokeMethod<dynamic>(
      'applyPushAuthority', iosSettings.toMap);
}

/// 设置 Tag （会覆盖之前设置的 tags）
Future<TagResultModel?> setJPushTags(List<String> tags) async {
  final Map<dynamic, dynamic>? map =
      await _channel.invokeMethod('setTags', tags);
  if (map != null) return TagResultModel.fromMap(map);
  return null;
}

/// 验证tag是否绑定
Future<TagResultModel?> validJPushTag(String tag) async {
  final Map<dynamic, dynamic>? map =
      await _channel.invokeMethod('validTag', tag);
  if (map != null) return TagResultModel.fromMap(map);
  return null;
}

/// 清空所有 tags。
Future<TagResultModel?> cleanJPushTags() async {
  final Map<dynamic, dynamic>? map = await _channel.invokeMethod('cleanTags');
  if (map != null) return TagResultModel.fromMap(map);
  return null;
}

/// 在原有 tags 的基础上添加 tags
Future<TagResultModel?> addJPushTags(List<String> tags) async {
  final Map<dynamic, dynamic>? map =
      await _channel.invokeMethod('addTags', tags);
  if (map != null) return TagResultModel.fromMap(map);
  return null;
}

/// 删除指定的 tags
Future<TagResultModel?> deleteJPushTags(List<String> tags) async {
  final Map<dynamic, dynamic>? map =
      await _channel.invokeMethod('deleteTags', tags);
  if (map != null) return TagResultModel.fromMap(map);
  return null;
}

/// 获取所有当前绑定的 tags
Future<TagResultModel?> getAllJPushTags() async {
  final Map<dynamic, dynamic>? map = await _channel.invokeMethod('getAllTags');
  if (map != null) return TagResultModel.fromMap(map);
  return null;
}

/// 获取 alias.
Future<AliasResultModel?> getJPushAlias() async {
  final Map<dynamic, dynamic>? map = await _channel.invokeMethod('getAlias');
  if (map != null) return AliasResultModel.fromMap(map);
  return null;
}

/// 重置 alias.
Future<AliasResultModel?> setJPushAlias(String alias) async {
  final Map<dynamic, dynamic>? map =
      await _channel.invokeMethod('setAlias', alias);
  if (map != null) return AliasResultModel.fromMap(map);
  return null;
}

/// 删除原有 alias
Future<AliasResultModel?> deleteJPushAlias() async {
  final Map<dynamic, dynamic>? map = await _channel.invokeMethod('deleteAlias');
  if (map != null) return AliasResultModel.fromMap(map);
  return null;
}

/// 设置应用 Badge（小红点）
/// 清空应用Badge（小红点）设置 badge = 0
/// 注意：如果是 Android 手机，目前仅支持华为手机
Future<bool?> setJPushBadge(int badge) =>
    _channel.invokeMethod('setBadge', badge);

/// 停止接收推送，调用该方法后应用将不再受到推送，如果想要重新收到推送可以调用 resumePush。
Future<bool?> stopJPush() => _channel.invokeMethod('stopPush');

/// 恢复推送功能。
Future<bool?> resumeJPush() => _channel.invokeMethod('resumePush');

/// 清空通知栏上的所有通知。
Future<bool?> clearAllJPushNotifications() =>
    _channel.invokeMethod<bool>('clearAllNotifications');

/// 清空通知栏上某个通知
Future<bool?> clearJPushNotification(int notificationId) =>
    _channel.invokeMethod('clearNotification', notificationId);

///
/// iOS Only
/// 点击推送启动应用的时候原生会将该 notification 缓存起来，该方法用于获取缓存 notification
/// 注意：notification 可能是 remoteNotification 和 localNotification，两种推送字段不一样。
/// 如果不是通过点击推送启动应用，比如点击应用 icon 直接启动应用，notification 会返回 @{}。
///
Future<Map<dynamic, dynamic>?> getJPushLaunchAppNotification() async {
  if (!Platform.isIOS) return null;
  return await _channel.invokeMethod('getLaunchAppNotification');
}

/// 获取 RegistrationId, JPush 可以通过制定 RegistrationId 来进行推送。
Future<String?> getJPushRegistrationID() =>
    _channel.invokeMethod('getRegistrationID');

/// 发送本地通知到调度器，指定时间出发该通知。
Future<LocalNotification?> sendJPushLocalNotification(
    LocalNotification notification) async {
  final bool? data = await _channel.invokeMethod<bool>(
      'sendLocalNotification', notification.toMap);
  if (data == null) return null;
  return notification;
}

///  检测通知授权状态是否打开
Future<bool?> isNotificationEnabled() =>
    _channel.invokeMethod<bool>('isNotificationEnabled');

///  Push Service 是否已经被停止
Future<bool?> isJPushStopped() async {
  if (!Platform.isAndroid) return true;
  return _channel.invokeMethod<bool>('isPushStopped');
}

/// 获取UDID
/// 仅支持android
Future<String?> getJPushUdID() async {
  if (!Platform.isAndroid) return null;
  return await _channel.invokeMethod<String>('getJPushUdID');
}

///  跳转至系统设置中应用设置界面
Future<void> openSettingsForNotification() =>
    _channel.invokeMethod('openSettingsForNotification');

/// 统一android ios 回传数据解析
class JPushMessage {
  JPushMessage({
    this.title,
    this.alert,
    this.extras,
    this.message,
    this.badge,
    this.notificationAuthorization,
  });

  JPushMessage.fromMap(Map<dynamic, dynamic> json) {
    notificationAuthorization = json['notificationAuthorization'] as bool;
    badge = json['badge'] as int;
    title = json['title'].toString();
    alert = json['alert'].toString();
    extras = json['extras'] as Map<dynamic, dynamic>;
    message = json['message'].toString();
  }

  String? title;
  String? alert;
  Map<dynamic, dynamic>? extras;
  String? message;

  /// only ios
  /// 监测通知授权状态返回结果
  bool? notificationAuthorization;
  String? body;
  String? sound;
  String? subtitle;
  int? badge;

  Map<String, dynamic> get toMap => <String, dynamic>{
        'title': title,
        'alert': alert,
        'extras': extras,
        'message': message,
        'subtitle': subtitle,
        'body': body,
        'sound': sound,
        'badge': badge,
        'notificationAuthorization': notificationAuthorization,
      };
}

class TagResultModel {
  TagResultModel({
    required this.code,
    this.tags,
    this.isBind,
  });

  TagResultModel.fromMap(Map<dynamic, dynamic> json) {
    code = json['code'] as int;
    isBind = json['isBind'] as bool;
    tags = json['tags'] != null
        ? (json['tags'] as List<dynamic>)
            .map((dynamic e) => e.toString())
            .toList()
        : null;
  }

  List<String>? tags;

  /// jPush状态🐴
  late int code;

  /// 校验tag 是否绑定
  bool? isBind;

  Map<String, dynamic> get toMap =>
      <String, dynamic>{'tags': tags, 'code': code, 'isBind': isBind};
}

class AliasResultModel {
  AliasResultModel({
    required this.code,
    this.alias,
  });

  AliasResultModel.fromMap(Map<dynamic, dynamic> json) {
    code = json['code'] as int;
    alias = json['alias'] as String;
    if (alias != null && alias!.isEmpty) alias = null;
  }

  String? alias;

  /// jPush状态🐴
  late int code;

  Map<String, dynamic> get toMap =>
      <String, dynamic>{'alias': alias, 'code': code};
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

  Map<String, dynamic> get toMap =>
      <String, bool>{'sound': sound, 'alert': alert, 'badge': badge};
}

///  {number} [buildId] - 通知样式：1 为基础样式，2 为自定义样式（需先调用 `setStyleCustom` 设置自定义样式）
///  {number} [id] - 通知 id, 可用于取消通知
///  {string} [title] - 通知标题
///  {string} [content] - 通知内容
///  {object} [extra] - extra 字段
///  {number} [fireTime] - 通知触发时间（毫秒）
///  iOS Only
///  {number} [badge] - 本地推送触发后应用角标值
///  iOS Only
///  {string} [soundName] - 指定推送的音频文件
///  iOS 10+ Only
///  {string} [subtitle] - 子标题
class LocalNotification {
  const LocalNotification(
      {required this.id,
      required this.title,
      required this.content,
      required this.fireTime,
      this.buildId,
      this.extra,
      this.badge = 0,
      this.soundName,
      this.subtitle});

  final int? buildId;
  final int id;
  final String title;
  final String content;
  final Map<String, String>? extra;
  final DateTime fireTime;
  final int badge;
  final String? soundName;
  final String? subtitle;

  Map<String, dynamic> get toMap => <String, dynamic>{
        'id': id,
        'title': title,
        'content': content,
        'fireTime': fireTime.millisecondsSinceEpoch,
        'buildId': buildId,
        'extra': extra,
        'badge': badge,
        'soundName': soundName,
        'subtitle': subtitle
      };
}

/// ios 回传数据解析
class _IOSModel {
  _IOSModel({this.aps, this.extras, this.notificationAuthorization});

  _IOSModel.fromJson(Map<dynamic, dynamic> json) {
    aps = json['aps'] != null
        ? _ApsModel.fromJson(json['aps'] as Map<dynamic, dynamic>)
        : null;
    extras = json['extras'] as Map<dynamic, dynamic>;
    notificationAuthorization = json['notificationAuthorization'] as bool;
  }

  bool? notificationAuthorization;
  _ApsModel? aps;
  Map<dynamic, dynamic>? extras;
}

class _ApsModel {
  _ApsModel({this.mutableContent, this.alert, this.badge, this.sound});

  _ApsModel.fromJson(Map<dynamic, dynamic> json) {
    mutableContent = json['mutable-content'] as int;
    alert = json['alert'] != null
        ? _AlertModel.fromJson(json['alert'] as Map<dynamic, dynamic>)
        : null;
    badge = json['badge'] as int;
    sound = json['sound'] as String;
  }

  int? mutableContent;
  _AlertModel? alert;
  int? badge;
  String? sound;
}

class _AlertModel {
  _AlertModel({this.subtitle, this.title, this.body});

  _AlertModel.fromJson(Map<dynamic, dynamic> json) {
    subtitle = json['subtitle'].toString();
    title = json['title'].toString();
    body = json['body'].toString();
  }

  String? subtitle;
  String? title;
  String? body;
}
