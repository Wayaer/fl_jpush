import 'package:fl_jverify/fl_jverify.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

void main() {
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, title: '极光认证', home: HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = 'Unknown';

  @override
  void initState() {
    super.initState();
    addPostFrameCallback((_) {
      setup();
    });
  }

  void setup() async {
    final result = await FlJVerify().setup(iosKey: '');
    if (result == null) return;
    text = result.toMap().toString();
    await setCustomAuthorizationView();
    setState(() {});
    checkVerifyEnable();
    FlJVerify().addEventHandler(authPageEventListener: (JVerifyResult result) {
      if (kDebugMode) {
        print('authPageEventListener===  ${result.toMap()}');
      }
    }, clickWidgetEventListener: (String id) {
      if (kDebugMode) {
        print('clickWidgetEventListener===  $id');
      }
    });
  }

  void checkVerifyEnable() async {
    await FlJVerify().dismissLoginAuthPage();
    final result = await FlJVerify().checkVerifyEnable();
    text = result.toString();
    setState(() {});
  }

  Future<void> setCustomAuthorizationView() async {
    final result = await JVerifyUI.setUiConfig();
    text = result.toString();
    setState(() {});
  }

  void loginAuth() async {
    final result = await FlJVerify().loginAuth(autoDismiss: true);
    if (result == null) return;
    text = result.toMap().toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBar(title: const Text('极光认证 Flutter')),
        padding: const EdgeInsets.all(20),
        children: [
          Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(10),
              height: 130,
              child: Text(text, style: const TextStyle(fontSize: 12))),
          Wrap(
              spacing: 12,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                ElevatedText('setup', onPressed: setup),
                ElevatedText('setDebugMode', onPressed: () async {
                  final result = await FlJVerify().setDebugMode(true);
                  text = result.toString();
                  setState(() {});
                }),
                ElevatedText('isInitSuccess', onPressed: () async {
                  final result = await FlJVerify().isInitSuccess();
                  text = result.toString();
                  setState(() {});
                }),
                ElevatedText('checkVerifyEnable', onPressed: checkVerifyEnable),
                ElevatedText('getToken', onPressed: () async {
                  final result = await FlJVerify().getToken();
                  if (result == null) return;
                  text = result.toMap().toString();
                  setState(() {});
                }),
                ElevatedText('preLogin', onPressed: () async {
                  final result = await FlJVerify().preLogin();
                  if (result == null) return;
                  text = result.toMap().toString();
                  setState(() {});
                }),
                ElevatedText('setCustomAuthorizationView',
                    onPressed: setCustomAuthorizationView),
                ElevatedText('loginAuth', onPressed: loginAuth),
                ElevatedText('clearPreLoginCache', onPressed: () async {
                  final result = await FlJVerify().clearPreLoginCache();
                  text = result.toString();
                  setState(() {});
                }),
                ElevatedText('getSMSCode', onPressed: () async {
                  final result = await FlJVerify().getSMSCode(phone: '');
                  if (result == null) return;
                  text = result.toMap().toString();
                  setState(() {});
                }),
                ElevatedText('setSmsIntervalTime', onPressed: () async {
                  final result = await FlJVerify().setSmsIntervalTime(1000);
                  text = result.toString();
                  setState(() {});
                }),
                ElevatedText('dismissLoginAuthPage', onPressed: () async {
                  final result = await FlJVerify().dismissLoginAuthPage();
                  text = result.toString();
                  setState(() {});
                }),
              ])
        ]);
  }
}

class ElevatedText extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  const ElevatedText(this.title, {Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onPressed, child: Text(title));
}

class JVerifyUI {
  JVerifyUI._();

  static Future<bool> setUiConfig() async {
    if (isIOS) {
      return await setIOSUiConfig();
    } else if (isAndroid) {
      return await setAndroidUiConfig();
    }
    return false;
  }

  static Future<bool> setIOSUiConfig() async {
    JVIOSUIConfig config = JVIOSUIConfig();

    config.navColor = Colors.white.value;
    config.navText = '';
    config.navTextColor = Colors.black.value;
    config.navReturnImgPath = 'back'; //图片必须存在

    config.logoWidth = 100;
    config.logoHeight = 80;
    config.logoOffsetY = 10;
    config.logoVerticalLayout = JVLayoutItem.superView;
    config.logoHidden = false;
    config.logoImgPath = 'logo';

    config.numberFieldWidth = 200;
    config.numberFieldHeight = 40;
    config.numFieldOffsetY = 20;
    config.numberVerticalLayout = JVLayoutItem.logo;
    config.numberColor = Colors.black.value;
    config.numberSize = 18;

    config.sloganOffsetY = 20;
    config.sloganVerticalLayout = JVLayoutItem.number;
    config.sloganTextColor = Colors.black.value;
    config.sloganTextSize = 15;
//        config.slogan
    //config.sloganHidden = 0;
    config.logoImgPath = 'logo';
    config.logoOffsetY = 100;
    config.logoWidth = 90;
    config.logoHeight = 90;
    config.loginButtonWidth = 220;
    config.loginButtonHeight = 50;
    config.loginButtonOffsetY = 20;
    config.loginButtonText = '授权登录';
    config.loginButtonTextColor = Colors.white.value;
    config.loginButtonTextSize = 20;
    config.loginButtonVerticalLayout = JVLayoutItem.slogan;
    config.loginBtnNormalImage = 'login_btn_press';
    config.loginBtnPressedImage = 'login_btn_press';
    config.loginBtnUnableImage = 'login_btn_press';
    config.privacyHintToast = true;
    config.privacyState = true; //设置默认勾选
    config.privacyCheckboxSize = 18;
    config.checkedImgPath = 'check'; //图片必须存在
    config.uncheckedImgPath = 'uncheck'; //图片必须存在
    config.privacyCheckboxInCenter = true;
    config.privacyText = ['请勾选', ''];
    config.privacyCheckboxHidden = false;
    config.privacyOffsetY = 10; // 距离底部距离
    config.clauseBaseColor = Colors.blue.value;
    config.privacyTextSize = 13;
    config.privacy = [
      JVPrivacy('协议', 'http://www.baidu.com', separator: '*'),
    ];
    config.clauseColor = Colors.blueAccent.value;
    config.textVerAlignment = 1;
    config.privacyWithBookTitleMark = true;
    config.privacyTextCenterGravity = true;
    config.authStatusBarStyle = JVStatusBarStyle.darkContent;
    config.privacyStatusBarStyle = JVStatusBarStyle.defaultStyle;
    config.modelTransitionStyle = JVIOSUIModalTransitionStyle.crossDissolve;
    config.needStartAnim = true;
    config.privacyNavColor = Colors.blueAccent.value;
    config.privacyNavTitleTextColor = Colors.black.value;
    config.privacyNavTitleTextSize = 16;
    config.privacyNavTitleTitle = '运营商协议政策'; //only ios
    config.privacyNavReturnBtnImage = 'back'; //图片必须存在;
    config.modelTransitionStyle = JVIOSUIModalTransitionStyle.coverVertical;
    final value = await FlJVerify().setAuthorizationView(config);
    log('设置ios 认证UI $value');
    return value;
  }

  static Future<bool> setAndroidUiConfig() async {
    JVAndroidUIConfig config = JVAndroidUIConfig();
    config.navColor = Colors.white.value;
    config.navText = '';
    config.navTextColor = Colors.black.value;
    config.navReturnImgPath = 'back'; //图片必须存在
    config.statusBarTransparent = true;

    config.logoHidden = false;
    config.logoWidth = 90;
    config.logoHeight = 90;

    config.numberFieldWidth = 200;
    config.numberFieldHeight = 40;
    config.numberColor = Colors.black.value;
    config.numberSize = 18;

    config.sloganTextColor = Colors.black.value;
    config.sloganTextSize = 15;

    config.loginButtonWidth = 220;
    config.loginButtonHeight = 50;
    config.loginButtonText = '授权登录';
    config.loginButtonTextColor = Colors.white.value;
    config.loginButtonTextSize = 20;
    config.loginButtonBackgroundPath = 'login_btn_bg';

    config.privacyHintToast = true;
    config.privacyState = true; //设置默认勾选
    config.privacyCheckboxSize = 18;
    config.checkedImgPath = 'check'; //图片必须存在
    config.uncheckedImgPath = 'uncheck'; //图片必须存在
    config.privacyCheckboxInCenter = true;
    config.privacyText = ['请勾选', ''];
    config.privacyCheckboxHidden = false;
    // config.privacyOffsetY = 10; // 距离底部距离
    config.clauseBaseColor = Colors.black.value;
    config.privacyTextSize = 13;
    config.privacy = [
      // JVPrivacy('协议', 'http://www.baidu.com', separator: '*'),
    ];
    config.clauseColor = Colors.blue.value;
    config.privacyWithBookTitleMark = true;
    config.privacyTextCenterGravity = true;
    config.needStartAnim = true;
    config.privacyNavColor = Colors.blue.value;
    config.privacyNavTitleTextColor = Colors.black.value;
    config.privacyNavTitleTextSize = 16;
    config.privacyNavReturnBtnImage = 'back'; //图片必须存在;
    final value = await FlJVerify().setAuthorizationView(config);
    log('设置android 认证UI $value');
    return value;
  }
}
