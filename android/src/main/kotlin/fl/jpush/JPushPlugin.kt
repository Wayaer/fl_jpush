package fl.jpush

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
import cn.jpush.android.ups.JPushUPSManager
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
        var hasOnReceiveMessage = false
        var hasOnOpenNotification = false
        var hasOnReceiveNotification = false
    }


    override fun onAttachedToEngine(plugin: FlutterPluginBinding) {
        channel = MethodChannel(plugin.binaryMessenger, "fl_jpush")
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

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        channelResult = result
        when (call.method) {
            "setup" -> {
                val map = call.arguments<HashMap<String, Any>>()
                JPushInterface.setDebugMode(map["debug"] as Boolean)
                JPushUPSManager.registerToken(
                    context,
                    map["appKey"] as String?, null, null
                ) {
                    result.success(it.returnCode == 0)
                    if (it.returnCode == 0) {
                        JPushInterface.setChannel(
                            context,
                            map["channel"] as String?
                        )
                    }
                }
            }
            "setTags" -> {
                val sequence = getSequence()
                val tagList = call.arguments<List<String>>()
                val tags: Set<String> = HashSet(tagList)
                JPushInterface.setTags(context, sequence, tags)
            }
            "validTag" -> {
                val sequence = getSequence()
                val tag = call.arguments
                JPushInterface.checkTagBindState(
                    context,
                    sequence,
                    tag.toString()
                )
            }
            "cleanTags" -> {
                val sequence = getSequence()
                JPushInterface.cleanTags(context, sequence)
            }
            "addTags" -> {
                val sequence = getSequence()
                val tagList = call.arguments<List<String>>()
                val tags: Set<String> = HashSet(tagList)
                JPushInterface.addTags(context, sequence, tags)
            }
            "deleteTags" -> {
                val sequence = getSequence()
                val tagList = call.arguments<List<String>>()
                val tags: Set<String> = HashSet(tagList)
                JPushInterface.deleteTags(context, sequence, tags)
            }
            "getAllTags" -> {
                val sequence: Int = getSequence()
                JPushInterface.getAllTags(context, sequence)
            }
            "getAlias" -> {
                val sequence = getSequence()
                JPushInterface.getAlias(context, sequence)
            }
            "setAlias" -> {
                val sequence = getSequence()
                val alias = call.arguments<String>()
                JPushInterface.setAlias(context, sequence, alias)
            }
            "deleteAlias" -> {
                val sequence = getSequence()
                JPushInterface.deleteAlias(context, sequence)
            }
            "stopPush" -> {
                JPushInterface.stopPush(context)
                result.success(true)
            }
            "resumePush" -> {
                JPushInterface.resumePush(context)
                result.success(true)
            }
            "clearAllNotifications" -> {
                JPushInterface.clearAllNotifications(context)
                result.success(true)
            }
            "clearNotification" -> {
                val id = call.arguments
                if (id != null) {
                    JPushInterface.clearNotificationById(context, id as Int)
                }
                result.success(id != null)
            }
            "getLaunchAppNotification" -> {
                result.success(null)
            }
            "getRegistrationID" -> {
                JPushInterface.requestPermission(context)
                result.success(JPushInterface.getRegistrationID(context))
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
                result.success(true)
            }
            "setBadge" -> {
                val badge = call.arguments as Int
                JPushInterface.setBadgeNumber(context, badge)
                result.success(true)
            }
            "isNotificationEnabled" -> {
                val isEnabled = JPushInterface.isNotificationEnabled(context)
                //1表示开启，0表示关闭，-1表示检测失败
                result.success(isEnabled == 1)
            }
            "isPushStopped" -> result.success(
                JPushInterface.isPushStopped(context)
            )
            "getUdID" -> result.success(JPushInterface.getUdid(context))
            "openSettingsForNotification" -> {
                JPushInterface.goToAppNotificationSettings(context)
                result.success(true)
            }
            "setEventHandler" -> {
                hasOnOpenNotification =
                    call.argument<Boolean>("onOpenNotification") == true
                hasOnReceiveMessage =
                    call.argument<Boolean>("onReceiveMessage") == true
                hasOnReceiveNotification =
                    call.argument<Boolean>("onReceiveNotification") == true
                result.success(true)
            }
            else -> result.notImplemented()

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
                    if (!hasOnReceiveMessage) {
                        return
                    }
                    val message =
                        intent.getStringExtra(JPushInterface.EXTRA_MESSAGE)
                    val extras = getNotificationExtras(intent)
                    val msg: MutableMap<String, Any?> = HashMap()
                    msg["message"] = message
                    msg["extras"] = extras
                    channel.invokeMethod("onReceiveMessage", msg)
                }
                JPushInterface.ACTION_NOTIFICATION_RECEIVED -> {
                    if (!hasOnReceiveNotification) {
                        return
                    }
                    val title =
                        intent.getStringExtra(JPushInterface.EXTRA_NOTIFICATION_TITLE)
                    val alert =
                        intent.getStringExtra(JPushInterface.EXTRA_ALERT)
                    val extras = getNotificationExtras(intent)
                    val notification: MutableMap<String, Any?> = HashMap()
                    notification["title"] = title
                    notification["alert"] = alert
                    notification["extras"] = extras
                    channel.invokeMethod("onReceiveNotification", notification)
                }
                JPushInterface.ACTION_NOTIFICATION_OPENED -> {
                    if (!hasOnOpenNotification) {
                        return
                    }
                    val title =
                        intent.getStringExtra(JPushInterface.EXTRA_NOTIFICATION_TITLE)
                    val alert =
                        intent.getStringExtra(JPushInterface.EXTRA_ALERT)
                    val extras = getNotificationExtras(intent)

                    val notification: MutableMap<String, Any?> = HashMap()
                    notification["title"] = title
                    notification["alert"] = alert
                    notification["extras"] = extras
                    channel.invokeMethod("onOpenNotification", notification)

                    val launch =
                        context!!.packageManager.getLaunchIntentForPackage(
                            context.packageName
                        )
                    if (launch != null) {
                        launch.addCategory(Intent.CATEGORY_LAUNCHER)
                        launch.flags =
                            Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                        context.startActivity(launch)
                    }
                }
            }
        }


        private fun getNotificationExtras(intent: Intent?): Map<String?, Any?> {
            val extrasMap: MutableMap<String?, Any?> = HashMap()
            for (key in intent!!.extras!!.keySet()) {
                extrasMap[key] = intent.extras!!.get(key)
            }
            return extrasMap
        }
    }

    class JPushEventReceiver : JPushMessageReceiver() {

        override fun onTagOperatorResult(
            context: Context?,
            jPushMessage: JPushMessage?
        ) {
            super.onTagOperatorResult(context, jPushMessage)
            val res: MutableMap<String, Any?> = HashMap()
            res["code"] = jPushMessage?.errorCode
            if (jPushMessage?.tags != null) res["tags"] =
                jPushMessage.tags.toList()
            handle.post {
                channelResult?.success(res)
                channelResult = null
            }
        }

        override fun onCheckTagOperatorResult(
            context: Context?,
            jPushMessage: JPushMessage?
        ) {
            super.onCheckTagOperatorResult(context, jPushMessage)
            val res: MutableMap<String, Any?> = HashMap()
            res["code"] = jPushMessage?.errorCode
            res["isBind"] = jPushMessage?.tagCheckStateResult
            if (jPushMessage?.tags != null) res["tags"] =
                jPushMessage.tags.toList()
            handle.post {
                channelResult?.success(res)
                channelResult = null
            }
        }


        override fun onAliasOperatorResult(
            context: Context?,
            jPushMessage: JPushMessage?
        ) {
            super.onAliasOperatorResult(context, jPushMessage)
            val res: MutableMap<String, Any?> = HashMap()
            res["alias"] = jPushMessage?.alias
            res["code"] = jPushMessage?.errorCode
            handle.post {
                channelResult?.success(res)
                channelResult = null
            }
        }
    }
}
