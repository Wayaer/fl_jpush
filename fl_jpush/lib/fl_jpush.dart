import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'model.dart';

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
  void addEventHandler({
    FlJPushEventHandler? eventHandler,
    FlJPushIOSEventHandler? iosEventHandler,
    FlJPushAndroidEventHandler? androidEventHandler,
  }) {
    if (!_supportPlatform) return;
    _channel.setMethodCallHandler((MethodCall call) async {
      try {
        JPushMessage buildMessage() =>
            JPushMessage.fromMap(call.arguments as Map<dynamic, dynamic>);
        switch (call.method) {
          case 'onOpenNotification':
            eventHandler?.onOpenNotification?.call(buildMessage());
            break;
          case 'onReceiveNotification':
            eventHandler?.onReceiveNotification?.call(buildMessage());
            break;
          case 'onReceiveMessage':
            iosEventHandler?.onReceiveMessage?.call(buildMessage());
            break;
          case 'onReceiveNotificationAuthorization':
            iosEventHandler?.onReceiveNotificationAuthorization
                ?.call(call.arguments as bool? ?? false);
            break;
          case 'onOpenSettingsForNotification':
            iosEventHandler?.onOpenSettingsForNotification
                ?.call(buildMessage());
            break;
          case 'onCommandResult':
            androidEventHandler?.onCommandResult?.call(
                FlJPushCmdMessage(call.arguments as Map<dynamic, dynamic>));
            break;
          case 'onConnected':
            androidEventHandler?.onConnected?.call(call.arguments as bool);
            break;
          case 'onNotifyMessageDismiss':
            androidEventHandler?.onNotifyMessageDismiss?.call(buildMessage());
            break;
          case 'onMultiActionClicked':
            androidEventHandler?.onMultiActionClicked
                ?.call(call.arguments as String?);
            break;
          case 'onMessage':
            androidEventHandler?.onMessage?.call(buildMessage());
            break;
        }
      } catch (_) {
        debugPrint(_.toString());
      }
    });
  }

  /// iOS Only
  /// 申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。
  Future<bool> applyAuthorityWithIOS(
      [NotificationSettingsWithIOS iosSettings =
          const NotificationSettingsWithIOS()]) async {
    if (!_isIOS) return false;
    final bool? state = await _channel.invokeMethod<bool?>(
        'applyPushAuthority', iosSettings.toMap());
    return state ?? false;
  }

  /// android 请求权限
  Future<bool> requestPermission() async {
    if (!_isAndroid) return false;
    final bool? state = await _channel.invokeMethod<bool?>('requestPermission');
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
  Future<bool?> sendLocalNotification({
    required LocalNotificationWithAndroid android,
    required LocalNotificationWithIOS ios,
  }) async {
    if (!_supportPlatform) return false;
    final result = await _channel.invokeMethod<bool>(
        'sendLocalNotification', _isAndroid ? android.toMap() : ios.toMap());
    return result ?? false;
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
