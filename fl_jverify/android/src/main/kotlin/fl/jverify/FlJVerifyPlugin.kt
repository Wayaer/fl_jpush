package fl.jverify

import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Paint
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.StateListDrawable
import android.view.Gravity
import android.widget.Button
import android.widget.RelativeLayout
import android.widget.TextView
import cn.jiguang.verifysdk.api.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.lang.reflect.Field

/**
 * FlJVerifyPlugin
 */
class FlJVerifyPlugin : FlutterPlugin, MethodCallHandler {
    private var context: Context? = null
    private var channel: MethodChannel? = null

    /// 错误码
    private val codeKey = "code"

    /// 回调的提示信息，统一返回 flutter 为 message
    private val msgKey = "message"

    /// 运营商信息
    private val oprKey = "operator"

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fl_jverify")
        channel!!.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel!!.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setup" -> {
                val timeout = call.argument<Int>("timeout")
                val setControlWifiSwitch = call.argument<Boolean>("setControlWifiSwitch")!!
                if (!setControlWifiSwitch) {
                    setControlWifiSwitch()
                }
                JVerificationInterface.init(context, timeout!!) { code, message ->
                    result.success(
                        mapOf(
                            codeKey to code, msgKey to message
                        )
                    )
                }
            }
            "setDebugMode" -> {
                JVerificationInterface.setDebugMode(call.arguments as Boolean)
                result.success(true)
            }
            "isInitSuccess" -> {
                result.success(JVerificationInterface.isInitSuccess())
            }
            "checkVerifyEnable" -> {
                result.success(JVerificationInterface.checkVerifyEnable(context))
            }
            "getToken" -> {
                JVerificationInterface.getToken(
                    context, call.arguments as Int
                ) { code, message, operator ->
                    result.success(
                        mapOf(
                            codeKey to code, msgKey to message, oprKey to operator
                        )
                    )
                }
            }
            "preLogin" -> {
                JVerificationInterface.preLogin(context, call.arguments as Int) { code, message ->
                    result.success(
                        mapOf(
                            codeKey to code, msgKey to message
                        )
                    )
                }
            }
            "loginAuth" -> {
                val autoFinish = call.argument<Boolean>("autoDismiss")!!
                val timeOut = call.argument<Int>("timeout")
                val settings = LoginSettings()
                settings.isAutoFinish = autoFinish
                settings.timeout = timeOut!!
                settings.authPageEventListener = object : AuthPageEventListener() {
                    override fun onEvent(code: Int, msg: String) {
                        channel!!.invokeMethod(
                            "onReceiveAuthPageEvent", mapOf(
                                codeKey to code, msgKey to msg
                            )
                        )
                    }
                }
                JVerificationInterface.loginAuth(context, settings) { code, msg, operator ->
                    result.success(
                        mapOf(
                            codeKey to code, msgKey to msg, oprKey to operator
                        )
                    )
                }
            }
            "setCustomAuthorizationView" -> {
                val portraitConfig = call.argument<Map<*, *>>("portraitConfig")!!
                val landscapeConfig = call.argument<Map<*, *>?>("landscapeConfig")
                val widgetList = call.argument<List<Map<*, *>>>("widgets")

                val portraitBuilder = JVerifyUIConfig.Builder()
                val landscapeBuilder = JVerifyUIConfig.Builder()


                /// 布局 SDK 授权界面原有 UI
                layoutOriginOauthView(portraitConfig, portraitBuilder)
                if (landscapeConfig != null) {
                    layoutOriginOauthView(landscapeConfig, landscapeBuilder)
                }
                if (widgetList != null) {
                    for (widgetMap in widgetList) {
                        /// 新增自定义的控件
                        val type = widgetMap["type"] as String?
                        if (type == "textView") {
                            addCustomTextWidgets(widgetMap, portraitBuilder)
                            if (landscapeConfig != null) {
                                addCustomTextWidgets(widgetMap, landscapeBuilder)
                            }
                        } else if (type == "button") {
                            addCustomButtonWidgets(widgetMap, portraitBuilder)
                            if (landscapeConfig != null) {
                                addCustomButtonWidgets(widgetMap, landscapeBuilder)
                            }
                        }
                    }
                }
                val portrait = portraitBuilder.build()
                if (landscapeConfig != null) {
                    val landscape = landscapeBuilder.build()
                    JVerificationInterface.setCustomUIWithConfig(portrait, landscape)
                } else {
                    JVerificationInterface.setCustomUIWithConfig(portrait)
                }
                result.success(true)
            }
            "dismissLoginAuthPage" -> {
                JVerificationInterface.dismissLoginAuthActivity()
                result.success(true)
            }
            "clearPreLoginCache" -> {
                JVerificationInterface.clearPreLoginCache()
                result.success(true)
            }
            "getSMSCode" -> {
                val phoneNum = call.argument<String>("phone")
                val signId = call.argument<String>("signId")
                val tempId = call.argument<String>("tempId")
                JVerificationInterface.getSmsCode(context, phoneNum, signId, tempId) { code, msg ->
                    result.success(
                        mapOf(
                            codeKey to code,
                            msgKey to msg,
                        )
                    )
                }
            }
            "setSmsIntervalTime" -> {
                JVerificationInterface.setSmsIntervalTime((call.arguments as Int).toLong())
                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun setControlWifiSwitch() {
        try {
            val aClass = JVerificationInterface::class.java
            val method = aClass.getDeclaredMethod(
                "setControlWifiSwitch", Boolean::class.javaPrimitiveType
            )
            method.isAccessible = true
            method.invoke(aClass, false)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * 自定义 SDK 原有的授权界面里的 UI
     */
    private fun layoutOriginOauthView(uiConfig: Map<*, *>, builder: JVerifyUIConfig.Builder) {
        /************* 状态栏  *******/
        val statusBarColorWithNav = valueForKey(uiConfig, "statusBarColorWithNav")
        val statusBarDarkMode = valueForKey(uiConfig, "statusBarDarkMode")
        val statusBarTransparent = valueForKey(uiConfig, "statusBarTransparent")
        val statusBarHidden = valueForKey(uiConfig, "statusBarHidden")
        if (statusBarColorWithNav != null) {
            builder.setStatusBarColorWithNav((statusBarColorWithNav as Boolean?)!!)
        }
        if (statusBarDarkMode != null) {
            builder.setStatusBarDarkMode((statusBarDarkMode as Boolean?)!!)
        }
        if (statusBarTransparent != null) {
            builder.setStatusBarTransparent((statusBarTransparent as Boolean?)!!)
        }
        if (statusBarHidden != null) {
            builder.setStatusBarHidden((statusBarHidden as Boolean?)!!)
        }
        val virtualButtonTransparent = valueForKey(uiConfig, "virtualButtonTransparent")
        if (virtualButtonTransparent != null) {
            builder.setVirtualButtonTransparent((virtualButtonTransparent as Boolean?)!!)
        }
        /************** web页  */
        val privacyStatusBarColorWithNav = valueForKey(uiConfig, "privacyStatusBarColorWithNav")
        val privacyStatusBarDarkMode = valueForKey(uiConfig, "privacyStatusBarDarkMode")
        val privacyStatusBarTransparent = valueForKey(uiConfig, "privacyStatusBarTransparent")
        val privacyStatusBarHidden = valueForKey(uiConfig, "privacyStatusBarHidden")
        val privacyVirtualButtonTransparent =
            valueForKey(uiConfig, "privacyVirtualButtonTransparent")
        if (privacyStatusBarColorWithNav != null) {
            builder.setPrivacyStatusBarColorWithNav((privacyStatusBarColorWithNav as Boolean?)!!)
        }
        if (privacyStatusBarDarkMode != null) {
            builder.setPrivacyStatusBarDarkMode((privacyStatusBarDarkMode as Boolean?)!!)
        }
        if (privacyStatusBarTransparent != null) {
            builder.setPrivacyStatusBarTransparent((privacyStatusBarTransparent as Boolean?)!!)
        }
        if (privacyStatusBarHidden != null) {
            builder.setPrivacyStatusBarHidden((privacyStatusBarHidden as Boolean?)!!)
        }
        if (privacyVirtualButtonTransparent != null) {
            builder.setPrivacyVirtualButtonTransparent((privacyVirtualButtonTransparent as Boolean?)!!)
        }
        /************** 动画支持  */
        val needStartAnim = valueForKey(uiConfig, "needStartAnim")
        val needCloseAnim = valueForKey(uiConfig, "needCloseAnim")
        if (needStartAnim != null) {
            builder.setNeedStartAnim((needStartAnim as Boolean?)!!)
        }
        if (needCloseAnim != null) {
            builder.setNeedCloseAnim((needCloseAnim as Boolean?)!!)
        }
        val enterAnim = valueForKey(uiConfig, "enterAnim")
        val exitAnim = valueForKey(uiConfig, "exitAnim")
        if (enterAnim != null && exitAnim != null) {
            val enterA = ResourceUtil.getAnimId(context!!, enterAnim as String?)
            val exitA = ResourceUtil.getAnimId(context!!, exitAnim as String?)
            if (enterA >= 0 && exitA >= 0) {
                builder.overridePendingTransition(enterA, exitA)
            }
        }
        /************** 背景  */


        val authBackgroundImage = valueForKey(uiConfig, "authBackgroundImage")


        if (authBackgroundImage != null) {
            val resId = getResourceByReflect(authBackgroundImage as String?)
            if (resId > 0) {
                builder.setAuthBGImgPath(authBackgroundImage as String?)
            }
        }
        val authBGGifPath = valueForKey(uiConfig, "authBGGifPath")
        if (authBGGifPath != null) {
            val resId = getResourceByReflect(authBGGifPath as String?)
            if (resId > 0) {
                builder.setAuthBGGifPath(authBGGifPath as String?)
            }
        }
        var authBGVideoPath = valueForKey(uiConfig, "authBGVideoPath")
        val authBGVideoImgPath = valueForKey(uiConfig, "authBGVideoImgPath")
        if (authBGVideoPath != null) {
            if (!(authBGVideoPath as String).startsWith("http")) authBGVideoPath =
                "android.resource://" + context!!.packageName + "/raw/" + authBGVideoPath
            builder.setAuthBGVideoPath(authBGVideoPath as String?, authBGVideoImgPath as String?)
        }
        /************** nav  */
        val navColor = valueForKey(uiConfig, "navColor")
        val navText = valueForKey(uiConfig, "navText")
        val navTextColor = valueForKey(uiConfig, "navTextColor")
        val navTextBold = valueForKey(uiConfig, "navTextBold")
        val navReturnImgPath = valueForKey(uiConfig, "navReturnImgPath")
        val navHidden = valueForKey(uiConfig, "navHidden")
        val navReturnBtnHidden = valueForKey(uiConfig, "navReturnBtnHidden")
        val navTransparent = valueForKey(uiConfig, "navTransparent")
        if (navHidden != null) {
            builder.setNavHidden((navHidden as Boolean?)!!)
        }
        if (navReturnBtnHidden != null) {
            builder.setNavReturnBtnHidden((navReturnBtnHidden as Boolean?)!!)
        }
        if (navTransparent != null) {
            builder.setNavTransparent((navTransparent as Boolean?)!!)
        }
        if (navColor != null) {
            builder.setNavColor(exchangeObject(navColor))
        }
        if (navText != null) {
            builder.setNavText(navText as String?)
        }
        if (navTextColor != null) {
            builder.setNavTextColor(exchangeObject(navTextColor))
        }
        if (navTextBold != null) {
            builder.setNavTextBold((navTextBold as Boolean?)!!)
        }
        if (navReturnImgPath != null) {
            builder.setNavReturnImgPath(navReturnImgPath as String?)
        }
        /************** logo  */
        val logoImgPath = valueForKey(uiConfig, "logoImgPath")
        val logoWidth = valueForKey(uiConfig, "logoWidth")
        val logoHeight = valueForKey(uiConfig, "logoHeight")
        val logoOffsetY = valueForKey(uiConfig, "logoOffsetY")
        val logoOffsetX = valueForKey(uiConfig, "logoOffsetX")
        val logoHidden = valueForKey(uiConfig, "logoHidden")
        val logoOffsetBottomY = valueForKey(uiConfig, "logoOffsetBottomY")
        if (logoWidth != null) {
            builder.setLogoWidth((logoWidth as Int?)!!)
        }
        if (logoHeight != null) {
            builder.setLogoHeight((logoHeight as Int?)!!)
        }
        if (logoOffsetY != null) {
            builder.setLogoOffsetY((logoOffsetY as Int?)!!)
        }
        if (logoOffsetX != null) {
            builder.setLogoOffsetX((logoOffsetX as Int?)!!)
        }
        if (logoHidden != null) {
            builder.setLogoHidden((logoHidden as Boolean?)!!)
        }
        if (logoImgPath != null) {
            val resId = getResourceByReflect(logoImgPath as String?)
            if (resId > 0) {
                builder.setLogoImgPath(logoImgPath as String?)
            }
        }
        if (logoOffsetBottomY != null) {
            builder.setLogoOffsetBottomY((logoOffsetBottomY as Int?)!!)
        }
        /************** number  */

        val numberColor = valueForKey(uiConfig, "numberColor")
        val numberSize = valueForKey(uiConfig, "numberSize")
        val numberTextBold = valueForKey(uiConfig, "numberTextBold")
        val numFieldOffsetY = valueForKey(uiConfig, "numFieldOffsetY")
        val numFieldOffsetX = valueForKey(uiConfig, "numFieldOffsetX")
        val numberFieldOffsetBottomY = valueForKey(uiConfig, "numberFieldOffsetBottomY")
        val numberFieldWidth = valueForKey(uiConfig, "numberFieldWidth")
        val numberFieldHeight = valueForKey(uiConfig, "numberFieldHeight")
        if (numberFieldOffsetBottomY != null) {
            builder.setNumberFieldOffsetBottomY((numberFieldOffsetBottomY as Int?)!!)
        }
        if (numFieldOffsetY != null) {
            builder.setNumFieldOffsetY((numFieldOffsetY as Int?)!!)
        }
        if (numFieldOffsetX != null) {
            builder.setNumFieldOffsetX((numFieldOffsetX as Int?)!!)
        }
        if (numberFieldWidth != null) {
            builder.setNumberFieldWidth((numberFieldWidth as Int?)!!)
        }
        if (numberFieldHeight != null) {
            builder.setNumberFieldHeight((numberFieldHeight as Int?)!!)
        }
        if (numberColor != null) {
            builder.setNumberColor(exchangeObject(numberColor))
        }
        if (numberSize != null) {
            builder.setNumberSize(numberSize as Number?)
        }
        if (numberTextBold != null) {
            builder.setNumberTextBold((numberTextBold as Boolean?)!!)
        }
        /************** slogan  */
        val sloganOffsetY = valueForKey(uiConfig, "sloganOffsetY")
        val sloganTextColor = valueForKey(uiConfig, "sloganTextColor")
        val sloganOffsetX = valueForKey(uiConfig, "sloganOffsetX")
        val sloganBottomOffsetY = valueForKey(uiConfig, "sloganBottomOffsetY")
        val sloganTextSize = valueForKey(uiConfig, "sloganTextSize")
        val sloganHidden = valueForKey(uiConfig, "sloganHidden")
        val sloganTextBold = valueForKey(uiConfig, "sloganTextBold")
        if (sloganOffsetY != null) {
            builder.setSloganOffsetY((sloganOffsetY as Int?)!!)
        }
        if (sloganOffsetX != null) {
            builder.setSloganOffsetX((sloganOffsetX as Int?)!!)
        }
        if (sloganBottomOffsetY != null) {
            builder.setSloganBottomOffsetY((sloganBottomOffsetY as Int?)!!)
        }
        if (sloganTextSize != null) {
            builder.setSloganTextSize((sloganTextSize as Int?)!!)
        }
        if (sloganTextColor != null) {
            builder.setSloganTextColor(exchangeObject(sloganTextColor))
        }
        if (sloganHidden != null) {
            builder.setSloganHidden((sloganHidden as Boolean?)!!)
        }
        if (sloganTextBold != null) {
            builder.setSloganTextBold((sloganTextBold as Boolean?)!!)
        }
        /************** login btn  */
        val loginButtonText = valueForKey(uiConfig, "loginButtonText")
        val loginButtonOffsetY = valueForKey(uiConfig, "loginButtonOffsetY")
        val loginButtonOffsetX = valueForKey(uiConfig, "loginButtonOffsetX")
        val loginButtonBottomOffsetY = valueForKey(uiConfig, "loginButtonBottomOffsetY")
        val loginButtonWidth = valueForKey(uiConfig, "loginButtonWidth")
        val loginButtonHeight = valueForKey(uiConfig, "loginButtonHeight")
        val loginButtonTextSize = valueForKey(uiConfig, "loginButtonTextSize")
        val loginButtonTextColor = valueForKey(uiConfig, "loginButtonTextColor")
        val loginButtonTextBold = valueForKey(uiConfig, "loginButtonTextBold")
        val loginButtonBackgroundPath = valueForKey(uiConfig, "loginButtonBackgroundPath")
        if (loginButtonOffsetY != null) {
            builder.setLogBtnOffsetY((loginButtonOffsetY as Int?)!!)
        }
        if (loginButtonOffsetX != null) {
            builder.setLogBtnOffsetX((loginButtonOffsetX as Int?)!!)
        }
        if (loginButtonBottomOffsetY != null) {
            builder.setLogBtnBottomOffsetY((loginButtonBottomOffsetY as Int?)!!)
        }
        if (loginButtonWidth != null) {
            builder.setLogBtnWidth((loginButtonWidth as Int?)!!)
        }
        if (loginButtonHeight != null) {
            builder.setLogBtnHeight((loginButtonHeight as Int?)!!)
        }
        if (loginButtonText != null) {
            builder.setLogBtnText(loginButtonText as String?)
        }
        if (loginButtonTextSize != null) {
            builder.setLogBtnTextSize((loginButtonTextSize as Int?)!!)
        }
        if (loginButtonTextColor != null) {
            builder.setLogBtnTextColor(exchangeObject(loginButtonTextColor))
        }
        if (loginButtonTextBold != null) {
            builder.setLogBtnTextBold((loginButtonTextBold as Boolean?)!!)
        }
        if (loginButtonBackgroundPath != null) {
            val resId = getResourceByReflect(loginButtonBackgroundPath as String?)
            if (resId > 0) {
                builder.setLogBtnImgPath(loginButtonBackgroundPath as String?)
            }
        }
        /************** check box  */
        val uncheckedImgPath = valueForKey(uiConfig, "uncheckedImgPath")
        val checkedImgPath = valueForKey(uiConfig, "checkedImgPath")
        val privacyCheckboxHidden = valueForKey(uiConfig, "privacyCheckboxHidden")
        val privacyCheckboxSize = valueForKey(uiConfig, "privacyCheckboxSize")

        builder.setPrivacyCheckboxHidden((privacyCheckboxHidden as Boolean?)!!)
        if (privacyCheckboxSize != null) {
            builder.setPrivacyCheckboxSize((privacyCheckboxSize as Int?)!!)
        }
        if (uncheckedImgPath != null) {
            val resId = getResourceByReflect(uncheckedImgPath as String?)
            if (resId > 0) {
                builder.setUncheckedImgPath(uncheckedImgPath as String?)
            }
        }
        if (checkedImgPath != null) {
            val resId = getResourceByReflect(checkedImgPath as String?)
            if (resId > 0) {
                builder.setCheckedImgPath(checkedImgPath as String?)
            }
        }
        if (privacyCheckboxSize != null) {
            builder.setPrivacyCheckboxSize((privacyCheckboxSize as Int?)!!)
        }
        /************** privacy  */

        val privacyTopOffsetY = valueForKey(uiConfig, "privacyTopOffsetY")
        val privacyOffsetY = valueForKey(uiConfig, "privacyOffsetY")
        val privacyOffsetX = valueForKey(uiConfig, "privacyOffsetX")
        val clauseBaseColor = valueForKey(uiConfig, "clauseBaseColor")
        val clauseColor = valueForKey(uiConfig, "clauseColor")
        val privacyTextBold = valueForKey(uiConfig, "privacyTextBold")

        if (privacyOffsetY != null) {
            //设置隐私条款相对于授权页面底部下边缘y偏移
            builder.setPrivacyOffsetY((privacyOffsetY as Int?)!!)
        } else {
            if (privacyTopOffsetY != null) {
                //设置隐私条款相对导航栏下端y轴偏移。since 2.4.8
                builder.setPrivacyTopOffsetY((privacyTopOffsetY as Int?)!!)
            }
        }
        if (privacyOffsetX != null) {
            builder.setPrivacyOffsetX((privacyOffsetX as Int?)!!)
        }

        val privacyTextSize = valueForKey(uiConfig, "privacyTextSize")
        if (privacyTextSize != null) {
            builder.setPrivacyTextSize((privacyTextSize as Int?)!!)
        }

        val privacyText = valueForKey(uiConfig, "privacyText") as ArrayList<*>?
        if (privacyText != null && privacyText.size >= 2) {
            builder.setPrivacyText(privacyText[0] as String, privacyText[1] as String)
        }
        if (privacyTextBold != null) {
            builder.setPrivacyTextBold((privacyTextBold as Boolean?)!!)
        }
        val privacyUnderlineText = valueForKey(uiConfig, "privacyUnderlineText")
        if (privacyUnderlineText != null) {
            builder.setPrivacyUnderlineText((privacyUnderlineText as Boolean?)!!)
        }
        builder.setPrivacyTextCenterGravity(
            valueForKey(
                uiConfig, "privacyTextCenterGravity"
            ) as Boolean
        )
        builder.setPrivacyWithBookTitleMark(
            valueForKey(
                uiConfig, "privacyWithBookTitleMark"
            ) as Boolean
        )
        builder.setPrivacyCheckboxInCenter(
            valueForKey(
                uiConfig, "privacyCheckboxInCenter"
            ) as Boolean
        )
        builder.setPrivacyState(valueForKey(uiConfig, "privacyState") as Boolean)
        val privacy = valueForKey(uiConfig, "privacy") as ArrayList<*>?
        if (privacy != null) {
            val privacyBeans = ArrayList<PrivacyBean>()
            var privacyBean: PrivacyBean
            for (map in privacy) {
                map as Map<*, *>
                privacyBean = PrivacyBean(
                    map["name"] as String, map["url"] as String, map["separator"] as String
                )
                privacyBeans.add(privacyBean)
            }
            builder.setPrivacyNameAndUrlBeanList(privacyBeans)
        }
        var baseColor = -10066330
        var color = -16007674
        if (clauseBaseColor != null) {
            baseColor = if (clauseBaseColor is Long) {
                clauseBaseColor.toInt()
            } else {
                clauseBaseColor as Int
            }
        }
        if (clauseColor != null) {
            color = if (clauseColor is Long) {
                clauseColor.toInt()
            } else {
                clauseColor as Int
            }
        }
        builder.setAppPrivacyColor(baseColor, color)
        /************** 隐私 web 页面  */
        val privacyNavColor = valueForKey(uiConfig, "privacyNavColor")
        if (privacyNavColor != null) {
            builder.setPrivacyNavColor(exchangeObject(privacyNavColor))
        }
        val privacyNavTitleTextSize = valueForKey(uiConfig, "privacyNavTitleTextSize")
        if (privacyNavTitleTextSize != null) {
            builder.setPrivacyNavTitleTextSize(exchangeObject(privacyNavTitleTextSize))
        }
        val privacyNavTitleTextColor = valueForKey(uiConfig, "privacyNavTitleTextColor")

        if (privacyNavTitleTextColor != null) {
            builder.setPrivacyNavTitleTextColor(exchangeObject(privacyNavTitleTextColor))
        }

        val privacyNavTitleTextBold = valueForKey(uiConfig, "privacyNavTitleTextBold")
        if (privacyNavTitleTextBold != null) {
            builder.setPrivacyNavTitleTextBold((privacyNavTitleTextBold as Boolean?)!!)
        }
        val privacyNavReturnBtnPath = valueForKey(uiConfig, "privacyNavReturnBtnImage")
        if (privacyNavReturnBtnPath != null) {
            val resId = getResourceByReflect(privacyNavReturnBtnPath as String?)
            if (resId > 0) {
                builder.setPrivacyNavReturnBtnPath(privacyNavReturnBtnPath as String?)
            }
        }
        builder.enableHintToast(valueForKey(uiConfig, "privacyHintToast") as Boolean, null)
        /************** 授权页弹窗模式  */
        val popViewConfig = valueForKey(uiConfig, "popViewConfig")
        if (popViewConfig != null) {
            val popViewConfigMap = popViewConfig as Map<*, *>
            val isPopViewTheme = valueForKey(popViewConfigMap, "isPopViewTheme")
            if ((isPopViewTheme as Boolean?)!!) {
                val width = valueForKey(popViewConfigMap, "width")
                val height = valueForKey(popViewConfigMap, "height")
                val offsetCenterX = valueForKey(popViewConfigMap, "offsetCenterX")
                val offsetCenterY = valueForKey(popViewConfigMap, "offsetCenterY")
                val isBottom = valueForKey(popViewConfigMap, "isBottom")
                builder.setDialogTheme(
                    width as Int,
                    height as Int,
                    offsetCenterX as Int,
                    offsetCenterY as Int,
                    (isBottom as Boolean?)!!
                )
            }
        }
    }

    /** 添加自定义 widget 到 SDK 原有的授权界面里  */
    /**
     * 添加自定义 TextView
     */
    private fun addCustomTextWidgets(para: Map<*, *>, builder: JVerifyUIConfig.Builder) {
        val customView = TextView(context)

        //设置text
        val title = para["title"] as String?
        customView.text = title

        //设置字体颜色
        val titleColor = para["titleColor"]
        if (titleColor != null) {
            if (titleColor is Long) {
                customView.setTextColor(titleColor.toInt())
            } else {
                customView.setTextColor((titleColor as Int?)!!)
            }
        }

        //设置字体大小
        val font = para["titleFont"]
        if (font != null) {
            val titleFont = font as Double
            if (titleFont > 0) {
                customView.textSize = titleFont.toFloat()
            }
        }

        //设置背景颜色
        val backgroundColor = para["backgroundColor"]
        if (backgroundColor != null) {
            if (backgroundColor is Long) {
                customView.setBackgroundColor(backgroundColor.toInt())
            } else {
                customView.setBackgroundColor((backgroundColor as Int?)!!)
            }
        }

        //下划线
        val isShowUnderline = para["isShowUnderline"] as Boolean?
        if (isShowUnderline!!) {
            customView.paint.flags = Paint.UNDERLINE_TEXT_FLAG //下划线
            customView.paint.isAntiAlias = true //抗锯齿
        }

        //设置对齐方式
        val alignmet = para["textAlignment"]
        if (alignmet != null) {
            val textAlignment = alignmet as String
            val gravity = getAlignmentFromString(textAlignment)
            customView.gravity = gravity
        }
        val isSingleLine = para["isSingleLine"] as Boolean
        customView.isSingleLine = isSingleLine //设置是否单行显示，多余的就 ...
        val lines = para["lines"] as Int
        customView.setLines(lines) //设置行数

        // 位置
        val left = para["left"] as Int
        val top = para["top"] as Int
        val width = para["width"] as Int
        val height = para["height"] as Int
        val mLayoutParams1 = RelativeLayout.LayoutParams(
            RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT
        )
        mLayoutParams1.leftMargin = dp2Pix(context!!, left.toFloat())
        mLayoutParams1.topMargin = dp2Pix(context!!, top.toFloat())
        if (width > 0) {
            mLayoutParams1.width = dp2Pix(context!!, width.toFloat())
        }
        if (height > 0) {
            mLayoutParams1.height = dp2Pix(context!!, height.toFloat())
        }
        customView.layoutParams = mLayoutParams1

        builder.addCustomView(customView, false) { _, _ ->
            channel!!.invokeMethod("onReceiveClickWidgetEvent", para["widgetId"])
        }
    }

    /**
     * 添加自定义 button
     */
    private fun addCustomButtonWidgets(para: Map<*, *>, builder: JVerifyUIConfig.Builder) {
        val customView = Button(context)
        //设置text
        val title = para["title"] as String?
        customView.text = title

        //设置字体颜色
        val titleColor = para["titleColor"]
        if (titleColor != null) {
            if (titleColor is Long) {
                customView.setTextColor(titleColor.toInt())
            } else {
                customView.setTextColor((titleColor as Int?)!!)
            }
        }
        //设置字体大小
        val font = para["titleFont"]
        if (font != null) {
            val titleFont = font as Double
            if (titleFont > 0) {
                customView.textSize = titleFont.toFloat()
            }
        }
        //设置背景颜色
        val backgroundColor = para["backgroundColor"]
        if (backgroundColor != null) {
            if (backgroundColor is Long) {
                customView.setBackgroundColor(backgroundColor.toInt())
            } else {
                customView.setBackgroundColor((backgroundColor as Int?)!!)
            }
        }

        // 设置背景图（只支持 button 设置）
        val btnNormalImageName = para["btnNormalImageName"] as String?
        var btnPressedImageName = para["btnPressedImageName"] as String?
        if (btnPressedImageName == null) {
            btnPressedImageName = btnNormalImageName
        }
        setButtonSelector(customView, btnNormalImageName, btnPressedImageName)

        //下划线
        val isShowUnderline = para["isShowUnderline"] as Boolean?
        if (isShowUnderline!!) {
            customView.paint.flags = Paint.UNDERLINE_TEXT_FLAG //下划线
            customView.paint.isAntiAlias = true //抗锯齿
        }

        //设置对齐方式
        val alignment = para["textAlignment"]
        if (alignment != null) {
            val textAlignment = alignment as String
            val gravity = getAlignmentFromString(textAlignment)
            customView.gravity = gravity
        }
        val isSingleLine = para["isSingleLine"] as Boolean
        customView.isSingleLine = isSingleLine //设置是否单行显示，多余的就 ...
        val lines = para["lines"] as Int
        customView.setLines(lines) //设置行数

        // 位置
        val left = para["left"] as Int
        val top = para["top"] as Int
        val width = para["width"] as Int
        val height = para["height"] as Int
        val mLayoutParams1 = RelativeLayout.LayoutParams(
            RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT
        )
        mLayoutParams1.leftMargin = dp2Pix(context!!, left.toFloat())
        mLayoutParams1.topMargin = dp2Pix(context!!, top.toFloat())
        if (width > 0) {
            mLayoutParams1.width = dp2Pix(context!!, width.toFloat())
        }
        if (height > 0) {
            mLayoutParams1.height = dp2Pix(context!!, height.toFloat())
        }
        customView.layoutParams = mLayoutParams1
        builder.addCustomView(customView, false) { _, _ ->
            channel!!.invokeMethod("onReceiveClickWidgetEvent", para["widgetId"])
        }
    }


    /**
     * 获取对齐方式
     */
    private fun getAlignmentFromString(alignment: String?): Int {
        var a = 0
        if (alignment != null) {
            a = when (alignment) {
                "left" -> Gravity.START
                "top" -> Gravity.TOP
                "right" -> Gravity.END
                "bottom" -> Gravity.BOTTOM
                "center" -> Gravity.CENTER
                else -> Gravity.NO_GRAVITY
            }
        }
        return a
    }


    private fun valueForKey(para: Map<*, *>?, key: String): Any? {
        return if (para != null && para.containsKey(key)) {
            para[key]
        } else {
            null
        }
    }


    /**
     * 设置 button 背景图片点击效果
     *
     * @param button          按钮
     * @param normalImageName 常态下背景图
     * @param pressImageName  点击时背景图
     */
    private fun setButtonSelector(
        button: Button, normalImageName: String?, pressImageName: String?
    ) {
        val drawable = StateListDrawable()
        val res = context!!.resources
        val normalResId = getResourceByReflect(normalImageName)
        val selectResId = getResourceByReflect(pressImageName)
        val normalBmp = BitmapFactory.decodeResource(res, normalResId)
        val normalDrawable: Drawable = BitmapDrawable(res, normalBmp)
        val selectBmp = BitmapFactory.decodeResource(res, selectResId)
        val selectDrawable: Drawable = BitmapDrawable(res, selectBmp)

        // 未选中
        drawable.addState(intArrayOf(-android.R.attr.state_pressed), normalDrawable)
        //选中
        drawable.addState(intArrayOf(android.R.attr.state_pressed), selectDrawable)
        button.background = drawable
    }

    /**
     * 像素转化成 pix
     */
    private fun dp2Pix(context: Context, dp: Float): Int {
        return try {
            val density = context.resources.displayMetrics.density
            (dp * density + 0.5f).toInt()
        } catch (e: java.lang.Exception) {
            dp.toInt()
        }
    }

    private fun exchangeObject(ob: Any): Int {
        return if (ob is Long) {
            ob.toInt()
        } else {
            ob as Int
        }
    }

    /**
     * 获取图片名称获取图片的资源id的方法
     *
     * @param imageName 图片名
     * @return resId
     */
    private fun getResourceByReflect(imageName: String?): Int {
        val drawable: Class<*> = R.drawable::class.java
        val field: Field?
        var rId = 0
        if (imageName == null) {
            return rId
        }
        try {
            field = drawable.getField(imageName)
            rId = field.getInt(field.name)
        } catch (e: java.lang.Exception) {
            rId = 0
        }
        if (rId == 0) {
            rId = context!!.resources.getIdentifier(imageName, "drawable", context!!.packageName)
        }
        if (rId == 0) {
            rId = context!!.resources.getIdentifier(imageName, "mipmap", context!!.packageName)
        }
        return rId
    }
}