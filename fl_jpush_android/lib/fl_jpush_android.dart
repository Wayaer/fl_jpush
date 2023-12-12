import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FlJPushForAndroid {
  FlJPushForAndroid._();

  static const MethodChannel _channel = MethodChannel('fl_jpush_android');

  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
}
