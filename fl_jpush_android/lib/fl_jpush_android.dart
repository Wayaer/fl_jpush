import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FlJPushForAndroid {
  FlJPushForAndroid._();

  static const MethodChannel _channel = MethodChannel('fl_jpush_android');

  /// 请求OPPO通知权限
  static Future<bool> requestNotificationPermissionWithOPPO() async {
    if (!_isAndroid) return false;
    final bool? state = await _channel
        .invokeMethod<bool?>('requestNotificationPermissionWithOPPO');
    return state ?? false;
  }

  /// 校验魅族通知
  static Future<bool> checkNotificationMessageWithMEIZU() async {
    if (!_isAndroid) return false;
    final bool? state =
        await _channel.invokeMethod<bool?>('checkNotificationMessageWithMEIZU');
    return state ?? false;
  }

  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
}
