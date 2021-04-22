package flutter.jpush

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import cn.jpush.android.api.JPushInterface
import cn.jpush.android.api.JPushMessage
import cn.jpush.android.data.JPushLocalNotification
import cn.jpush.android.service.JPushMessageReceiver
import com.google.firebase.FirebaseApp
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.text.SimpleDateFormat
import java.util.*


class JPushPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var context: Context

    companion object {
        lateinit var channel: MethodChannel
        var channelResult: MethodChannel.Result? = null
        val handle = Handler(Looper.getMainLooper())
    }


    override fun onAttachedToEngine(plugin: FlutterPluginBinding) {
        channel = MethodChannel(plugin.binaryMessenger,
                "fl_jpush")
        channel.setMethodCallHandler(this)
        context = plugin.applicationContext
    }

    override fun onDetachedFromEngine(plugin: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    @SuppressLint("SimpleDateFormat")
    private fun getSequence(): Int {
        val sdf = SimpleDateFormat("MMddHHmmss")
        val date: String = sdf.format(Date())
        return Integer.valueOf(date)
    }

    override fun onMethodCall(call: MethodCall, _result: MethodChannel.Result) {
        channelResult = _result
        when (call.method) {
            "setup" -> {
                val map = call.arguments<HashMap<String, Any>>()
                val debug = map["debug"] as Boolean
                JPushInterface.setDebugMode(debug)
                JPushInterface.init(context) // 初始化 JPush
                val channel = map["channel"] as String?
                JPushInterface.setChannel(context, channel)
                FirebaseApp.initializeApp(context)
                channelResult!!.success(true)
            }
            "setTags" -> {
                val sequence: Int = getSequence()
                val tagList = call.arguments<List<String>>()
                val tags: Set<String> = HashSet(tagList)
                JPushInterface.setTags(context, sequence, tags)
            }
            "validTag" -> {
                val sequence: Int = getSequence()
                val tag = call.arguments
                JPushInterface.checkTagBindState(context, sequence, tag.toString())
            }
            "cleanTags" -> {
                val sequence: Int = getSequence()
                JPushInterface.cleanTags(context, sequence)
            }
            "addTags" -> {
                val sequence: Int = getSequence()
                val tagList = call.arguments<List<String>>()
                val tags: Set<String> = HashSet(tagList)
                JPushInterface.addTags(context, sequence, tags)
            }
            "deleteTags" -> {
                val sequence: Int = getSequence()
                val tagList = call.arguments<List<String>>()
                val tags: Set<String> = HashSet(tagList)
                JPushInterface.deleteTags(context, sequence, tags)
            }
            "getAllTags" -> {
                val sequence: Int = getSequence()
                JPushInterface.getAllTags(context, sequence)
            }
            "getAlias" -> {
                val sequence: Int = getSequence()
                JPushInterface.getAlias(context, sequence)
            }
            "setAlias" -> {
                val sequence: Int = getSequence()
                val alias = call.arguments<String>()
                JPushInterface.setAlias(context, sequence, alias)
            }
            "deleteAlias" -> {
                val sequence: Int = getSequence()
                JPushInterface.deleteAlias(context, sequence)
            }
            "stopPush" -> {
                JPushInterface.stopPush(context)
                channelResult!!.success(true)
            }
            "resumePush" -> {
                JPushInterface.resumePush(context)
                channelResult!!.success(true)
            }
            "clearAllNotifications" -> {
                JPushInterface.clearAllNotifications(context)
                channelResult!!.success(true)
            }
            "clearNotification" -> {
                val id = call.arguments
                if (id != null) {
                    JPushInterface.clearNotificationById(context, id as Int)
                    channelResult!!.success(true)
                } else {
                    channelResult!!.success(false)
                }
            }
            "getLaunchAppNotification" -> {

            }
            "getRegistrationID" -> {
                val rid = JPushInterface.getRegistrationID(context)
                channelResult!!.success(rid)
            }
            "sendLocalNotification" -> {
                val map = call.arguments<Map<String, Any>>()
                val ln = JPushLocalNotification()
                ln.builderId = (map["buildId"] as Int).toLong()
                ln.notificationId = (map["id"] as Int).toLong()
                ln.title = map["title"] as String?
                ln.content = map["content"] as String?
                ln.extras = (map["extra"] as Map<*, *>?).toString()
                ln.broadcastTime = map["fireTime"] as Long
                JPushInterface.addLocalNotification(context, ln)
                channelResult!!.success(true)
            }
            "setBadge" -> {
                val badge = call.arguments as Int
                JPushInterface.setBadgeNumber(context, badge)
                channelResult!!.success(true)
            }
            "isNotificationEnabled" -> {
                val isEnabled = JPushInterface.isNotificationEnabled(context)
                //1表示开启，0表示关闭，-1表示检测失败
                channelResult!!.success(isEnabled == 1)
            }
            "isPushStopped" -> channelResult!!.success(JPushInterface.isPushStopped(context))
            "getUdID" -> channelResult!!.success(JPushInterface.getUdid(context))
            "openSettingsForNotification" -> JPushInterface.goToAppNotificationSettings(context)
            else -> channelResult!!.notImplemented()

        }
    }

    /**
     * 接收自定义消息,通知,通知点击事件等事件的广播
     * 文档链接:http://docs.jiguang.cn/client/android_api/
     */
    class JPushReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent!!.action) {
                JPushInterface.ACTION_REGISTRATION_ID -> {
//                    val rId = intent.getStringExtra(JPushInterface.EXTRA_REGISTRATION_ID)
                }
                JPushInterface.ACTION_MESSAGE_RECEIVED -> {
                    val message = intent.getStringExtra(JPushInterface.EXTRA_MESSAGE)
                    val extras = getNotificationExtras(intent)
                    val msg: MutableMap<String, Any?> = HashMap()
                    msg["message"] = message
                    msg["extras"] = extras
                    channel.invokeMethod("onReceiveMessage", msg)
                }
                JPushInterface.ACTION_NOTIFICATION_RECEIVED -> {
                    val title = intent.getStringExtra(JPushInterface.EXTRA_NOTIFICATION_TITLE)
                    val alert = intent.getStringExtra(JPushInterface.EXTRA_ALERT)
                    val extras = getNotificationExtras(intent)
                    val notification: MutableMap<String, Any?> = HashMap()
                    notification["title"] = title
                    notification["alert"] = alert
                    notification["extras"] = extras
                    channel.invokeMethod("onReceiveNotification", notification)
                }
                JPushInterface.ACTION_NOTIFICATION_OPENED -> {
                    val title = intent.getStringExtra(JPushInterface.EXTRA_NOTIFICATION_TITLE)
                    val alert = intent.getStringExtra(JPushInterface.EXTRA_ALERT)
                    val extras = getNotificationExtras(intent)

                    val notification: MutableMap<String, Any?> = HashMap()
                    notification["title"] = title
                    notification["alert"] = alert
                    notification["extras"] = extras
                    channel.invokeMethod("onOpenNotification", notification)

                    val launch = context!!.packageManager.getLaunchIntentForPackage(context.packageName)
                    if (launch != null) {
                        launch.addCategory(Intent.CATEGORY_LAUNCHER)
                        launch.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                        context.startActivity(launch)
                    }
                }
            }
        }


        private fun getNotificationExtras(intent: Intent?): Map<String?, Any?> {
            val extrasMap: MutableMap<String?, Any?> = HashMap()
            for (key in intent!!.extras!!.keySet()) {
                if (!extrasKeys.contains(key)) {
                    if (key == JPushInterface.EXTRA_NOTIFICATION_ID) {
                        extrasMap[key] = intent.getIntExtra(key, 0)
                    } else {
                        extrasMap[key] = intent.getStringExtra(key)
                    }
                }
            }
            return extrasMap
        }

        private val extrasKeys = listOf("cn.jpush.android.TITLE",
                "cn.jpush.android.MESSAGE", "cn.jpush.android.APPKEY", "cn.jpush.android.NOTIFICATION_CONTENT_TITLE", "key_show_entity", "platform")
    }

    class JPushEventReceiver : JPushMessageReceiver() {

        override fun onTagOperatorResult(context: Context, jPushMessage: JPushMessage) {
            super.onTagOperatorResult(context, jPushMessage)
            val res: MutableMap<String, Any?> = HashMap()
            res["code"] = jPushMessage.errorCode
            if (jPushMessage.tags != null) res["tags"] = jPushMessage.tags.toList()
            handle.post {
                channelResult?.success(res)
            }
        }

        override fun onCheckTagOperatorResult(context: Context, jPushMessage: JPushMessage) {
            super.onCheckTagOperatorResult(context, jPushMessage)
            val res: MutableMap<String, Any?> = HashMap()
            res["code"] = jPushMessage.errorCode
            res["isBind"] = jPushMessage.tagCheckStateResult
            if (jPushMessage.tags != null) res["tags"] = jPushMessage.tags.toList()
            handle.post {
                channelResult?.success(res)
            }
        }

        override fun onAliasOperatorResult(context: Context, jPushMessage: JPushMessage) {
            super.onAliasOperatorResult(context, jPushMessage)
            val res: MutableMap<String, Any?> = HashMap()
            res["alias"] = jPushMessage.alias
            res["code"] = jPushMessage.errorCode
            handle.post {
                channelResult?.success(res)
            }
        }

    }
}