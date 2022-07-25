import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef JPushEventHandler = void Function(JPushMessage? event);
typedef JPushNotificationAuthorization = void Function(bool? state);

class FlJPush {
  factory FlJPush() => _singleton ??= FlJPush._();

  FlJPush._();

  static FlJPush? _singleton;

  final MethodChannel _channel = const MethodChannel('fl_jpush');

  Future<bool> setup(
      {required String appKey,
      bool production = false,
      String? channel = '',
      bool debug = false}) async {
    if (!_supportPlatform) return false;
    final bool? state = await _channel.invokeMethod<bool?>(
        'setup', <String, dynamic>{
      'appKey': appKey,
      'channel': channel,
      'production': production,
      'debug': debug
    });
    return state ?? false;
  }

  /// 初始化 JPush 必须先初始化才能执行其他操作(比如接收事件传递)
  Future<void> addEventHandler({
    /// 接收普通消息
    JPushEventHandler? onReceiveNotification,

    /// 点击通知栏消息回调
    JPushEventHandler? onOpenNotification,
    JPushEventHandler? onReceiveMessage,

    /// ios 获取消息认证 回调
    JPushNotificationAuthorization? onReceiveNotificationAuthorization,
  }) async {
    if (!_supportPlatform) return;
    await _channel.invokeMethod<bool?>('setEventHandler', {
      'onReceiveNotification': onReceiveNotification != null,
      'onOpenNotification': onOpenNotification != null,
      'onReceiveMessage': onReceiveMessage != null,
    });
    _channel.setMethodCallHandler((MethodCall call) async {
      JPushMessage? message;
      if (call.arguments is Map) {
        message = JPushMessage.fromMap(call.arguments as Map<dynamic, dynamic>);
      }
      switch (call.method) {
        case 'onReceiveNotification':
          onReceiveNotification?.call(message);
          break;
        case 'onOpenNotification':
          onOpenNotification?.call(message);
          break;
        case 'onReceiveMessage':
          onReceiveMessage?.call(message);
          break;
        case 'onReceiveNotificationAuthorization':
          onReceiveNotificationAuthorization?.call(call.arguments as bool?);
          break;
        default:
          throw UnsupportedError('Unrecognized Event');
      }
    });
  }

  /// iOS Only
  /// 申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。
  Future<bool> applyAuthorityWithIOS(
      [NotificationSettingsIOS iosSettings =
          const NotificationSettingsIOS()]) async {
    if (!_isIOS) return false;
    final bool? state = await _channel.invokeMethod<bool?>(
        'applyPushAuthority', iosSettings.toMap);
    return state ?? false;
  }

  /// 设置 Tag （会覆盖之前设置的 tags）
  Future<TagResultModel?> setTags(List<String> tags) async {
    if (!_supportPlatform) return null;
    final Map<dynamic, dynamic>? map =
        await _channel.invokeMethod('setTags', tags);
    if (map != null) return TagResultModel.fromMap(map);
    return null;
  }

  /// 验证tag是否绑定
  Future<TagResultModel?> validTag(String tag) async {
    if (!_supportPlatform) return null;
    final Map<dynamic, dynamic>? map =
        await _channel.invokeMethod('validTag', tag);
    if (map != null) return TagResultModel.fromMap(map, tag);
    return null;
  }

  /// 清空所有 tags。
  Future<TagResultModel?> cleanTags() async {
    if (!_supportPlatform) return null;
    final Map<dynamic, dynamic>? map = await _channel.invokeMethod('cleanTags');
    if (map != null) return TagResultModel.fromMap(map);
    return null;
  }

  /// 在原有 tags 的基础上添加 tags
  Future<TagResultModel?> addTags(List<String> tags) async {
    if (!_supportPlatform) return null;
    final Map<dynamic, dynamic>? map =
        await _channel.invokeMethod('addTags', tags);
    if (map != null) return TagResultModel.fromMap(map);
    return null;
  }

  /// 删除指定的 tags
  Future<TagResultModel?> deleteTags(List<String> tags) async {
    if (!_supportPlatform) return null;
    final Map<dynamic, dynamic>? map =
        await _channel.invokeMethod('deleteTags', tags);
    if (map != null) return TagResultModel.fromMap(map);
    return null;
  }

  /// 获取所有当前绑定的 tags
  Future<TagResultModel?> getAllTags() async {
    if (!_supportPlatform) return null;
    final Map<dynamic, dynamic>? map =
        await _channel.invokeMethod('getAllTags');
    if (map != null) return TagResultModel.fromMap(map);
    return null;
  }

  /// 获取 alias.
  Future<AliasResultModel?> getAlias() async {
    if (!_supportPlatform) return null;
    final Map<dynamic, dynamic>? map = await _channel.invokeMethod('getAlias');
    if (map != null) return AliasResultModel.fromMap(map);
    return null;
  }

  /// 重置 alias.
  Future<AliasResultModel?> setAlias(String alias) async {
    if (!_supportPlatform) return null;
    final Map<dynamic, dynamic>? map =
        await _channel.invokeMethod('setAlias', alias);
    if (map != null) return AliasResultModel.fromMap(map);
    return null;
  }

  /// 删除原有 alias
  Future<AliasResultModel?> deleteAlias() async {
    if (!_supportPlatform) return null;
    final Map<dynamic, dynamic>? map =
        await _channel.invokeMethod('deleteAlias');
    if (map != null) return AliasResultModel.fromMap(map);
    return null;
  }

  /// 设置应用 Badge（小红点）
  /// 清空应用Badge（小红点）设置 badge = 0
  /// 注意：如果是 Android 手机，目前仅支持华为手机
  Future<bool> setBadge(int badge) async {
    if (!_supportPlatform) return false;
    final bool? state = await _channel.invokeMethod<bool?>('setBadge', badge);
    return state ?? false;
  }

  /// 停止接收推送，调用该方法后应用将不再受到推送，如果想要重新收到推送可以调用 resumePush。
  Future<bool> stop() async {
    if (!_supportPlatform) return false;
    final bool? state = await _channel.invokeMethod<bool?>('stopPush');
    return state ?? false;
  }

  /// 恢复推送功能。
  Future<bool> resume() async {
    if (!_supportPlatform) return false;
    final bool? state = await _channel.invokeMethod<bool?>('resumePush');
    return state ?? false;
  }

  /// 清空通知栏上某个通知
  /// [notificationId] == null 清空通知栏上的所有通知。
  Future<bool> clearNotification({int? notificationId}) async {
    if (!_supportPlatform) return false;
    final bool? state =
        await _channel.invokeMethod<bool?>('clearNotification', notificationId);
    return state ?? false;
  }

  ///
  /// iOS Only
  /// 点击推送启动应用的时候原生会将该 notification 缓存起来，该方法用于获取缓存 notification
  /// 注意：notification 可能是 remoteNotification 和 localNotification，两种推送字段不一样。
  /// 如果不是通过点击推送启动应用，比如点击应用 icon 直接启动应用，notification 会返回 @{}。
  ///
  Future<Map<dynamic, dynamic>?> getLaunchAppNotificationWithIOS() async {
    if (!_isIOS) return null;
    return await _channel.invokeMethod('getLaunchAppNotification');
  }

  /// 获取 RegistrationId, JPush 可以通过制定 RegistrationId 来进行推送。
  Future<String?> getRegistrationID() async {
    if (!_supportPlatform) return null;
    return await _channel.invokeMethod('getRegistrationID');
  }

  /// 发送本地通知到调度器，指定时间出发该通知。
  Future<LocalNotification?> sendLocalNotification(
      LocalNotification notification) async {
    if (!_supportPlatform) return null;
    final bool? data = await _channel.invokeMethod<bool>(
        'sendLocalNotification', notification.toMap);
    if (data == null) return null;
    return notification;
  }

  ///  检测通知授权状态是否打开
  Future<bool?> isNotificationEnabled() async {
    if (!_supportPlatform) return null;
    return await _channel.invokeMethod<bool>('isNotificationEnabled');
  }

  ///  Push Service 是否已经被停止
  /// only android
  Future<bool?> isPushStopped() async {
    if (!_isAndroid) return true;
    return _channel.invokeMethod<bool>('isPushStopped');
  }

  /// 获取UDID
  /// only android
  Future<String?> getUDIDWithAndroid() async {
    if (!_isAndroid) return null;
    return await _channel.invokeMethod<String>('getUdID');
  }

  ///  跳转至系统设置中应用设置界面
  Future<bool> openSettingsForNotification() async {
    if (!_supportPlatform) return false;
    final bool? state =
        await _channel.invokeMethod<bool>('openSettingsForNotification');
    return state ?? false;
  }

  bool get _supportPlatform {
    if (!kIsWeb && (_isAndroid || _isIOS)) return true;
    debugPrint('Not support platform for $defaultTargetPlatform');
    return false;
  }

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;
}

/// 统一android ios 回传数据解析
class JPushMessage {
  JPushMessage({
    this.original,
    this.sound,
    this.alert,
    this.extras,
    this.message,
    this.badge,
    this.title,
    this.mutableContent,
    this.notificationAuthorization,
  });

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
      final Map<dynamic, dynamic>? _extras =
          json['extras'] as Map<dynamic, dynamic>?;
      if (_extras != null) {
        msgID = _extras['cn.jpush.android.MSG_ID'] as String?;
        notificationID = _extras['cn.jpush.android.NOTIFICATION_ID'] as int?;
        extras = _extras['cn.jpush.android.EXTRA'];
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

  Map<String, dynamic> get toMap => <String, dynamic>{
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
    alias = json['alias'] as String?;
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

  Map<String, dynamic> get toMap => {
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
