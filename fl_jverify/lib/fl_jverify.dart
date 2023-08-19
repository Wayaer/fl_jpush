import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef JVAuthPageEventListener = void Function(JVerifyResult result);

/// 监听添加的自定义控件的点击事件
typedef JVClickWidgetEventListener = void Function(String widgetId);

class FlJVerify {
  factory FlJVerify() => _singleton ??= FlJVerify._();

  FlJVerify._();

  static FlJVerify? _singleton;

  final MethodChannel _channel = const MethodChannel('fl_jverify');

  /// 初始化, timeout单位毫秒，合法范围是(0,30000]，推荐设置为5000-10000,默认值为10000
  Future<JVerifyResult?> setup(
      {

      /// ios 使用
      String? iosKey,
      String? channel,
      bool useIDFA = false,

      /// andorid 使用
      int timeout = 10000,
      bool setControlWifiSwitch = true}) async {
    if (!_supportPlatform) return null;
    if (_isIOS) assert(iosKey != null);
    final map = await _channel.invokeMethod<Map<dynamic, dynamic>?>('setup', {
      'iosKey': iosKey,
      'channel': channel,
      'useIDFA': useIDFA,
      'timeout': timeout,
      'setControlWifiSwitch': setControlWifiSwitch
    });
    return map == null ? null : JVerifyResult.fromJson(map);
  }

  /// 授权页回调监听
  void addEventHandler({
    JVAuthPageEventListener? authPageEventListener,
    JVClickWidgetEventListener? clickWidgetEventListener,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onReceiveAuthPageEvent':
          authPageEventListener?.call(JVerifyResult.fromJson(call.arguments));
          break;
        case 'onReceiveClickWidgetEvent':
          clickWidgetEventListener?.call(call.arguments);
          break;
      }
    });
  }

  /// 设置 debug 模式
  Future<bool> setDebugMode(bool debug) async {
    if (!_supportPlatform) return false;
    final state = await _channel.invokeMethod<bool?>('setDebugMode', debug);
    return state ?? false;
  }

  /// 获取 SDK 初始化是否成功标识
  Future<bool> isInitSuccess() async {
    if (!_supportPlatform) return false;
    final state = await _channel.invokeMethod<bool?>('isInitSuccess');
    return state ?? false;
  }

  /// SDK判断网络环境是否支持
  Future<bool> checkVerifyEnable() async {
    if (!_supportPlatform) return false;
    final state = await _channel.invokeMethod<bool?>('checkVerifyEnable');
    return state ?? false;
  }

  /*
   * SDK 获取号码认证token
   * return Map
   *        key = 'code', vlaue = 状态码，2000代表获取成功
   *        key = 'message', value = 成功即为 token，失败为提示
   * */
  Future<JVerifyResult?> getToken({int timeOut = 5000}) async {
    if (!_supportPlatform) return null;
    final map = await _channel.invokeMethod<Map<dynamic, dynamic>?>(
        'getToken', timeOut);
    return map == null ? null : JVerifyResult.fromJson(map);
  }

  /*
   * SDK 一键登录预取号,timeOut 有效取值范围[3000,10000]
   *
   * return Map
   *        key = 'code', vlaue = 状态码，7000代表获取成功
   *        key = 'message', value = 结果信息描述
   * */
  Future<JVerifyResult?> preLogin({int timeOut = 5000}) async {
    if (!_supportPlatform) return null;
    if (timeOut >= 3000 && timeOut <= 10000) {
      timeOut = timeOut;
    }
    final map = await _channel.invokeMethod<Map<dynamic, dynamic>?>(
        'preLogin', timeOut);
    return map == null ? null : JVerifyResult.fromJson(map);
  }

  /*
  * SDK请求授权一键登录
  *
  * @param autoDismiss  设置登录完成后是否自动关闭授权页
  * @param timeout      设置超时时间，单位毫秒。 合法范围（0，30000],范围以外默认设置为10000
  *
  * @return 通过接口异步返回的 map :
  *                           key = 'code', value = 6000 代表loginToken获取成功
  *                           key = message, value = 返回码的解释信息，若获取成功，内容信息代表loginToken
  *
  * @discussion since SDK v2.4.0，授权页面点击事件监听：通过添加 JVAuthPageEventListener 监听，来监听授权页点击事件
  *
  * */
  Future<JVerifyResult?> loginAuth(
      {bool autoDismiss = true, int timeout = 5000}) async {
    if (!_supportPlatform) return null;
    final map = await _channel.invokeMethod<Map<dynamic, dynamic>?>(
        'loginAuth', {'autoDismiss': autoDismiss, 'timeout': timeout});
    return map == null ? null : JVerifyResult.fromJson(map);
  }

  /*
  * 设置授权页面UI
  * @para portraitConfig    竖屏的 UI 配置 支持 ios 或者 android
  * @para landscapeConfig   Android 横屏的 UI 配置，该配置只生效在 Android
  * @para widgets           自定义添加的控件
  * */
  Future<bool> setAuthorizationView(JVGeneralUIConfig portraitConfig,
      {JVAndroidUIConfig? landscapeConfig,
      List<JVCustomWidget>? widgets}) async {
    Map<String, dynamic> para = {};
    if (_isAndroid) {
      assert(portraitConfig is JVAndroidUIConfig);
      para["portraitConfig"] = (portraitConfig as JVAndroidUIConfig).toMap();
      para["landscapeConfig"] = landscapeConfig?.toMap();
    } else {
      assert(portraitConfig is JVIOSUIConfig);
      para["portraitConfig"] = (portraitConfig as JVIOSUIConfig).toMap();
    }

    if (widgets != null) {
      var widgetList = [];
      for (JVCustomWidget widget in widgets) {
        var para2 = widget.toJsonMap();
        para2.removeWhere((key, value) => value == null);
        widgetList.add(para2);
      }
      para["widgets"] = widgetList;
    }
    final status =
        await _channel.invokeMethod<bool>("setCustomAuthorizationView", para);
    return status ?? false;
  }

  /*
   * SDK 获取短信验证码
   *        key = 'code', vlaue = 状态码，3000代表获取成功
   *        key = 'message', 提示信息
   *        key = 'result',uuid
   * */
  Future<JVerifyResult?> getSMSCode(
      {required String phone, String? signId, String? tempId}) async {
    if (!_supportPlatform) return null;
    final map = await _channel.invokeMethod<Map<dynamic, dynamic>?>(
        'getSMSCode', {'phone': phone, 'signId': signId, 'tempId': tempId});
    return map == null ? null : JVerifyResult.fromJson(map);
  }

  /// 设置前后两次获取验证码的时间间隔，默认 30000ms，有效范围(0,300000)
  Future<bool> setSmsIntervalTime(int intervalTime) async {
    if (!_supportPlatform) return false;
    final state =
        await _channel.invokeMethod<bool?>('setSmsIntervalTime', intervalTime);
    return state ?? false;
  }

  /// 清除预登录缓存
  Future<bool> clearPreLoginCache() async {
    if (!_supportPlatform) return false;
    final state = await _channel.invokeMethod<bool?>('clearPreLoginCache');
    return state ?? false;
  }

  /// 关闭授权页面
  Future<bool> dismissLoginAuthPage() async {
    if (!_supportPlatform) return false;
    final state = await _channel.invokeMethod<bool?>('dismissLoginAuthPage');
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

class JVerifyResult {
  /// 返回码，具体事件返回码请查看（https: /// docs.jiguang.cn/jverification/client/android_api/）
  int? code;

  /// 事件描述、事件返回值等
  String? message;

  /// 成功时为对应运营商，CM代表中国移动，CU代表中国联通，CT代表中国电信。失败时可能为null
  String? operator;

  /// iOS uuid
  String? result;

  JVerifyResult.fromJson(Map<dynamic, dynamic> json)
      : code = json['code'],
        message = json['message'],
        result = json['result'],
        operator = json['operator'];

  Map<String, dynamic> toMap() => {
        'code': code,
        'message': message,
        'operator': operator,
        'result': result
      };
}

/*
* 自定义 UI 界面配置类
*
* Y 轴
*     iOS       以导航栏底部为 0 作为起点
*     Android   以导航栏底部为 0 作为起点
* X 轴
*     iOS       以屏幕中心为 0 作为起点，往屏幕左侧则减，往右侧则加，如果不传或者传 null，则默认屏幕居中
*     Android   以屏幕左侧为 0 作为起点，往右侧则加，如果不传或者传 null，则默认屏幕居中
* */
class JVGeneralUIConfig {
  /// 授权页背景图片
  String? authBackgroundImage;

  /// 授权界面gif图片
  String? authBGGifPath;

  /// 授权界面video
  String? authBGVideoPath;

  /// 授权界面video的第一频图片
  String? authBGVideoImgPath;

  /// 导航栏
  int? navColor;
  String navText = '授权登录';
  int? navTextColor;
  String? navReturnImgPath;
  bool navHidden = false;
  bool navReturnBtnHidden = false;
  bool navTransparent = false;

  /// logo
  int? logoWidth;
  int? logoHeight;
  int? logoOffsetX;
  int? logoOffsetY;
  bool? logoHidden;
  String? logoImgPath;

  /// 号码
  int? numberColor;
  int? numberSize;
  int? numFieldOffsetX;
  int? numFieldOffsetY;
  int? numberFieldWidth;
  int? numberFieldHeight;

  /// slogan
  int? sloganOffsetX;
  int? sloganOffsetY;
  int? sloganTextColor;
  int? sloganTextSize;

  /// 登录按钮
  int? loginButtonOffsetX;
  int? loginButtonOffsetY;
  int? loginButtonWidth;
  int? loginButtonHeight;
  String? loginButtonText;
  int? loginButtonTextSize;
  int? loginButtonTextColor;

  /// 设置隐私条款不选中时点击登录按钮默认弹出toast。
  bool privacyHintToast = true;

  /// 设置隐私条款默认选中状态，默认不选中
  bool privacyState = false;

  /// 设置隐私条款checkbox是否隐藏
  bool privacyCheckboxHidden = false;

  /// 设置隐私条款checkbox是否相对协议文字纵向居中
  bool privacyCheckboxInCenter = false;

  /// 隐私条款相对于授权页面底部下边缘 y 偏移
  int? privacyOffsetY;

  /// 隐私条款相对于屏幕左边 x 轴偏移
  int? privacyOffsetX;

  List<String>? privacyText;
  int? privacyTextSize;
  List<JVPrivacy>? privacy;

  /// 选择框
  String? uncheckedImgPath;
  String? checkedImgPath;

  int? privacyCheckboxSize;
  int? clauseBaseColor;
  int? clauseColor;

  /// 设置隐私条款运营商协议名是否加书名号
  bool privacyWithBookTitleMark = true;

  /// 隐私条款文字是否居中对齐（默认左对齐）
  bool privacyTextCenterGravity = false;

  /// 隐私协议 web 页 UI 配置
  ///  导航栏颜色
  int? privacyNavColor;

  /// 标题颜色
  int? privacyNavTitleTextColor;

  /// 标题大小
  int? privacyNavTitleTextSize;

  String? privacyNavReturnBtnImage;

  /// 是否需要动画
  /// 设置拉起授权页时是否需要显示默认动画
  bool needStartAnim = false;

  /// 设置关闭授权页时是否需要显示默认动画
  bool needCloseAnim = false;

  /// 授权页弹窗模式 配置，选填
  JVPopViewConfig? popViewConfig;

  Map<String, dynamic> toMap() => {
        'privacy': privacy?.map((e) => e.toMap()).toList(),
        'authBackgroundImage': authBackgroundImage,
        'authBGGifPath': authBGGifPath,
        'authBGVideoPath': authBGVideoPath,
        'authBGVideoImgPath': authBGVideoImgPath,
        'navColor': navColor,
        'navText': navText,
        'navTextColor': navTextColor,
        'navReturnImgPath': navReturnImgPath,
        'navHidden': navHidden,
        'navReturnBtnHidden': navReturnBtnHidden,
        'navTransparent': navTransparent,
        'logoImgPath': logoImgPath,
        'logoWidth': logoWidth,
        'logoHeight': logoHeight,
        'logoOffsetY': logoOffsetY,
        'logoOffsetX': logoOffsetX,
        'logoHidden': logoHidden,
        'numberColor': numberColor,
        'numberSize': numberSize,
        'numFieldOffsetY': numFieldOffsetY,
        'numFieldOffsetX': numFieldOffsetX,
        'numberFieldWidth': numberFieldWidth,
        'numberFieldHeight': numberFieldHeight,
        'loginButtonText': loginButtonText,
        'loginButtonOffsetY': loginButtonOffsetY,
        'loginButtonOffsetX': loginButtonOffsetX,
        'loginButtonWidth': loginButtonWidth,
        'loginButtonHeight': loginButtonHeight,
        'loginButtonTextSize': loginButtonTextSize,
        'loginButtonTextColor': loginButtonTextColor,
        'uncheckedImgPath': uncheckedImgPath,
        'checkedImgPath': checkedImgPath,
        'privacyCheckboxSize': privacyCheckboxSize,
        'privacyHintToast': privacyHintToast,
        'privacyOffsetY': privacyOffsetY,
        'privacyOffsetX': privacyOffsetX,
        'privacyText': privacyText,
        'privacyTextSize': privacyTextSize,
        'clauseBaseColor': clauseBaseColor,
        'clauseColor': clauseColor,
        'sloganOffsetY': sloganOffsetY,
        'sloganTextColor': sloganTextColor,
        'sloganOffsetX': sloganOffsetX,
        'sloganTextSize': sloganTextSize,
        'privacyState': privacyState,
        'privacyCheckboxInCenter': privacyCheckboxInCenter,
        'privacyTextCenterGravity': privacyTextCenterGravity,
        'privacyCheckboxHidden': privacyCheckboxHidden,
        'privacyWithBookTitleMark': privacyWithBookTitleMark,
        'privacyNavColor': privacyNavColor,
        'privacyNavTitleTextColor': privacyNavTitleTextColor,
        'privacyNavTitleTextSize': privacyNavTitleTextSize,
        'privacyNavReturnBtnImage': privacyNavReturnBtnImage,
        'popViewConfig': popViewConfig?.toMap(),
        'needStartAnim': needStartAnim,
        'needCloseAnim': needCloseAnim,
      }..removeWhere((key, value) => value == null);
}

class JVIOSUIConfig extends JVGeneralUIConfig {
  /// 是否支持横屏
  bool isAutorotate = false;

  /// logo
  JVLayoutItem? logoVerticalLayout;

  /// 号码
  JVLayoutItem? numberVerticalLayout;

  /// slogan
  JVLayoutItem? sloganVerticalLayout;
  int? sloganWidth;
  int? sloganHeight;

  /// 登录按钮
  JVLayoutItem? loginButtonVerticalLayout;

  /// 登录按钮背景图需要设置三个参数才有效果
  String? loginBtnNormalImage;
  String? loginBtnPressedImage;
  String? loginBtnUnableImage;

  /// 隐私协议栏
  // JVLayoutItem privacyVerticalLayout = JVLayoutItem.superView;

  /// 设置条款文字是否垂直居中对齐(默认居中对齐) 0是top 1是m 2是b
  int? textVerAlignment = 1;

  /// 协议0 web页面导航栏标题 only ios
  String? privacyNavTitleTitle;

  /// 协议1 web页面导航栏标题
  String? privacyNavTitleTitle1;

  /// 协议2 web页面导航栏标题
  String? privacyNavTitleTitle2;

  /// 隐私协议web页 状态栏样式设置 only iOS
  JVStatusBarStyle? privacyStatusBarStyle;

  /// 授权页状态栏样式设置 only iOS
  JVStatusBarStyle authStatusBarStyle = JVStatusBarStyle.defaultStyle;

  /// 弹出方式 only ios
  JVIOSUIModalTransitionStyle modelTransitionStyle =
      JVIOSUIModalTransitionStyle.coverVertical;

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'isAutorotate': isAutorotate,
      'logoVerticalLayout': _getStringFromEnum(logoVerticalLayout),
      'numberVerticalLayout': _getStringFromEnum(numberVerticalLayout),
      'sloganVerticalLayout': _getStringFromEnum(sloganVerticalLayout),
      'sloganWidth': sloganWidth,
      'sloganHeight': sloganHeight,
      'loginButtonVerticalLayout':
          _getStringFromEnum(loginButtonVerticalLayout),
      'loginBtnNormalImage': loginBtnNormalImage,
      'loginBtnPressedImage': loginBtnPressedImage,
      'loginBtnUnableImage': loginBtnUnableImage,
      // 'privacyVerticalLayout': _getStringFromEnum(privacyVerticalLayout),
      'privacyNavTitleTitle': privacyNavTitleTitle,
      'privacyNavTitleTitle1': privacyNavTitleTitle1,
      'privacyNavTitleTitle2': privacyNavTitleTitle2,
      'authStatusBarStyle': _getStringFromEnum(authStatusBarStyle),
      'privacyStatusBarStyle': _getStringFromEnum(privacyStatusBarStyle),
      'modelTransitionStyle': _getStringFromEnum(modelTransitionStyle),
      'textVerAlignment': textVerAlignment,
    });
    return map..removeWhere((key, value) => value == null);
  }
}

class JVAndroidUIConfig extends JVGeneralUIConfig {
  /// 导航栏
  bool? navTextBold;

  /// logo
  int? logoOffsetBottomY;

  /// 号码
  bool? numberTextBold;
  int? numberFieldOffsetBottomY;

  /// slogan
  int? sloganBottomOffsetY;
  bool? sloganTextBold;
  bool sloganHidden = false;

  /// 登录按钮
  int? loginButtonBottomOffsetY;
  bool? loginButtonTextBold;
  String? loginButtonBackgroundPath;
  int? privacyTopOffsetY;
  bool? privacyTextBold;

  /// 设置隐私条款文字字体是否加下划线
  bool? privacyUnderlineText;

  /// 标题字体加粗
  bool? privacyNavTitleTextBold;

  /// 隐私页web状态栏是否与导航栏同色 only android
  bool privacyStatusBarColorWithNav = false;

  /// 隐私页web状态栏是否暗色 only android
  bool privacyStatusBarDarkMode = false;

  /// 隐私页web页状态栏是否透明 only android
  bool privacyStatusBarTransparent = false;

  /// 隐私页web页状态栏是否隐藏 only android
  bool privacyStatusBarHidden = false;

  /// 隐私页web页虚拟按键背景是否透明 only android
  bool privacyVirtualButtonTransparent = false;

  /// 授权页
  /// 授权页状态栏是否跟导航栏同色 only android
  bool statusBarColorWithNav = false;

  /// 授权页状态栏是否为暗色 only android
  bool statusBarDarkMode = false;

  /// 授权页栏状态栏是否透明 only android
  bool statusBarTransparent = false;

  /// 授权页状态栏是否隐藏 only android
  bool statusBarHidden = false;

  /// 授权页虚拟按键背景是否透明 only android
  bool virtualButtonTransparent = false;

  /// 拉起授权页时进入动画 only android
  String enterAnim = 'activity_slide_enter_bottom';

  /// 退出授权页时动画 only android
  String exitAnim = 'activity_slide_exit_bottom';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'navTextBold': navTextBold,
      'logoOffsetBottomY': logoOffsetBottomY,
      'numberTextBold': numberTextBold,
      'numberFieldOffsetBottomY': numberFieldOffsetBottomY,
      'loginButtonBottomOffsetY': loginButtonBottomOffsetY,
      'loginButtonTextBold': loginButtonTextBold,
      'loginButtonBackgroundPath': loginButtonBackgroundPath,
      'privacyTopOffsetY': privacyTopOffsetY,
      'privacyTextBold': privacyTextBold,
      'privacyUnderlineText': privacyUnderlineText,
      'sloganBottomOffsetY': sloganBottomOffsetY,
      'sloganHidden': sloganHidden,
      'sloganTextBold': sloganTextBold,
      'privacyNavTitleTextBold': privacyNavTitleTextBold,
      'privacyStatusBarColorWithNav': privacyStatusBarColorWithNav,
      'privacyStatusBarDarkMode': privacyStatusBarDarkMode,
      'privacyStatusBarTransparent': privacyStatusBarTransparent,
      'privacyStatusBarHidden': privacyStatusBarHidden,
      'privacyVirtualButtonTransparent': privacyVirtualButtonTransparent,
      'statusBarColorWithNav': statusBarColorWithNav,
      'statusBarDarkMode': statusBarDarkMode,
      'statusBarTransparent': statusBarTransparent,
      'statusBarHidden': statusBarHidden,
      'virtualButtonTransparent': virtualButtonTransparent,
      'enterAnim': enterAnim,
      'exitAnim': exitAnim,
    });
    return map..removeWhere((key, value) => value == null);
  }
}

/// 授权页弹窗模式配置
/// 注意：Android 的相关配置可以从 AndroidManifest 中配置，具体做法参考https: /// docs.jiguang.cn/jverification/client/android_api/#sdk_11

class JVPopViewConfig {
  int? width;
  int? height;

  /// 窗口相对屏幕中心的x轴偏移量
  int offsetCenterX = 0;

  /// 窗口相对屏幕中心的y轴偏移量
  int offsetCenterY = 0;

  /// only Android，窗口是否居屏幕底部。设置后 offsetCenterY 将失效，
  bool isBottom = false;

  /// only ios，弹窗圆角大小，Android 从 AndroidManifest 配置中读取
  double popViewCornerRadius = 5.0;

  /// only ios，背景的透明度，Android 从 AndroidManifest 配置中读取
  double backgroundAlpha = 0.3;

  /// 是否支持弹窗模式
  bool? isPopViewTheme;

  JVPopViewConfig() {
    isPopViewTheme = true;
  }

  Map<String, dynamic> toMap() => {
        'isPopViewTheme': isPopViewTheme,
        'width': width,
        'height': height,
        'offsetCenterX': offsetCenterX,
        'offsetCenterY': offsetCenterY,
        'isBottom': isBottom,
        'popViewCornerRadius': popViewCornerRadius,
        'backgroundAlpha': backgroundAlpha,
      }..removeWhere((key, value) => value == null);
}

///  自定义控件
class JVCustomWidget {
  String? widgetId;
  JVCustomWidgetType? type;

  JVCustomWidget(this.widgetId, this.type) {
    widgetId = widgetId;
    type = type;
    isClickEnable = type == JVCustomWidgetType.button;
  }

  int left = 0;

  /// 屏幕左边缘开始计算
  int top = 0;

  /// 导航栏底部开始计算
  int width = 0;
  int height = 0;

  String title = '';
  double titleFont = 13.0;
  int titleColor = Colors.black.value;
  int? backgroundColor;
  String? btnNormalImageName;
  String? btnPressedImageName;
  JVTextAlignmentType textAlignment = JVTextAlignmentType.center;

  int lines = 1;

  /// textView 行数，
  bool isSingleLine = true;

  /// textView 是否单行显示，默认：单行，iOS 端无效
  /// 若 isSingleLine = false 时，iOS 端 lines 设置失效，会自适应内容高度，最大高度为设置的 height */

  bool isShowUnderline = false;

  /// 是否显示下划线，默认：不显示
  bool isClickEnable = false;

  /// 是否可点击，默认：不可点击

  Map<String, dynamic> toJsonMap() => {
        'widgetId': widgetId,
        'type': _getStringFromEnum(type),
        'title': title,
        'titleFont': titleFont,
        'textAlignment': _getStringFromEnum(textAlignment),
        'titleColor': titleColor,
        'backgroundColor': backgroundColor,
        'isShowUnderline': isShowUnderline,
        'isClickEnable': isClickEnable,
        'btnNormalImageName': btnNormalImageName,
        'btnPressedImageName': btnPressedImageName,
        'lines': lines,
        'isSingleLine': isSingleLine,
        'left': left,
        'top': top,
        'width': width,
        'height': height,
      }..removeWhere((key, value) => value == null);
}

///  添加自定义控件类型，目前只支持 textView
enum JVCustomWidgetType { textView, button }

///  文本对齐方式
enum JVTextAlignmentType { left, right, center }

/*
* iOS 布局参照 item
*
* ItemNone    不参照任何item。可用来直接设置 Y、width、height
* ItemLogo    参照logo视图
* ItemNumber  参照号码栏
* ItemSlogan  参照标语栏
* ItemLogin   参照登录按钮
* ItemCheck   参照隐私选择框
* ItemPrivacy 参照隐私栏
* ItemSuper   参照父视图
* */
enum JVLayoutItem {
  none,
  logo,
  number,
  slogan,
  login,
  check,
  privacy,
  superView
}

/*
* iOS授权界面弹出模式
* 注意：窗口模式下不支持 PartialCurl
* */
enum JVIOSUIModalTransitionStyle {
  /// 下推
  coverVertical,

  /// 翻转
  flipHorizontal,

  /// 淡出
  crossDissolve,
  partialCurl
}
/*
*
* iOS状态栏设置，需要设置info.plist文件中
* View controller-based status barappearance值为YES
* 授权页和隐私页状态栏才会生效
*
* */
enum JVStatusBarStyle {
  /// Automatically chooses light or dark content based on the user interface style
  defaultStyle,

  /// Light content, for use on dark backgrounds iOS 7 以上
  lightContent,

  /// Dark content, for use on light backgrounds  iOS 13 以上
  darkContent
}

class JVPrivacy {
  String? name;
  String? url;

  /// ios分隔符专属
  String? separator;

  JVPrivacy(this.name, this.url, {this.separator});

  Map<String, dynamic> toMap() =>
      {'name': name, 'url': url, 'separator': separator};

  Map<String, dynamic> toJson() =>
      toMap()..removeWhere((key, value) => value == null);
}

String _getStringFromEnum<T>(T) {
  if (T == null) return '';
  return T.toString().split('.').last;
}
