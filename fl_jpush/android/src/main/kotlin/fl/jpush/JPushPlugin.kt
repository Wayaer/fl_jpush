package fl.jpush

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import cn.jpush.android.api.CmdMessage
import cn.jpush.android.api.CustomMessage
import cn.jpush.android.api.JPushInterface
import cn.jpush.android.api.JPushMessage
import cn.jpush.android.api.NotificationMessage
import cn.jpush.android.data.JPushLocalNotification
import cn.jpush.android.service.JPushMessageService
import cn.jpush.android.ups.JPushUPSManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.text.SimpleDateFormat
import java.util.*


class JPushPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var context: Context
    private lateinit var activity: Activity

    companion object {
        lateinit var channel: MethodChannel
        var channelResult: MethodChannel.Result? = null
        val handle = Handler(Looper.getMainLooper())
    }


    override fun onAttachedToEngine(plugin: FlutterPluginBinding) {
        channel = MethodChannel(plugin.binaryMessenger, "fl_jpush")
        channel.setMethodCallHandler(this)
        context = plugin.applicationContext
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }


    override fun onDetachedFromActivity() {
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
                val map = call.arguments<HashMap<String, Any>>()!!
                JPushInterface.setDebugMode(map["debug"] as Boolean)
                JPushUPSManager.registerToken(
                    activity, map["appKey"] as String?, null, null
                ) {
                    JPushInterface.setNotificationCallBackEnable(activity, true)
                    result.success(it.returnCode == 0)
                    if (it.returnCode == 0) {
                        JPushInterface.setChannel(
                            activity, map["channel"] as String?
                        )
                    }
                }
            }

            "setTags" -> {
                val sequence = getSequence()
                val tagList = call.arguments<List<String>>()!!
                val tags: Set<String> = HashSet(tagList)
                JPushInterface.setTags(activity, sequence, tags)
            }

            "validTag" -> {
                val sequence = getSequence()
                val tag = call.arguments
                JPushInterface.checkTagBindState(
                    activity, sequence, tag.toString()
                )
            }

            "cleanTags" -> {
                val sequence = getSequence()
                JPushInterface.cleanTags(activity, sequence)
            }

            "addTags" -> {
                val sequence = getSequence()
                val tagList = call.arguments<List<String>>()!!
                val tags: Set<String> = HashSet(tagList)
                JPushInterface.addTags(activity, sequence, tags)
            }

            "deleteTags" -> {
                val sequence = getSequence()
                val tagList = call.arguments<List<String>>()!!
                val tags: Set<String> = HashSet(tagList)
                JPushInterface.deleteTags(activity, sequence, tags)
            }

            "getAllTags" -> {
                val sequence: Int = getSequence()
                JPushInterface.getAllTags(activity, sequence)
            }

            "getAlias" -> {
                val sequence = getSequence()
                JPushInterface.getAlias(activity, sequence)
            }

            "setAlias" -> {
                val sequence = getSequence()
                val alias = call.arguments<String>()
                JPushInterface.setAlias(activity, sequence, alias)
            }

            "deleteAlias" -> {
                val sequence = getSequence()
                JPushInterface.deleteAlias(activity, sequence)
            }

            "stopPush" -> {
                JPushInterface.stopPush(activity)
                result.success(true)
            }

            "resumePush" -> {
                JPushInterface.resumePush(activity)
                result.success(true)
            }

            "clearNotification" -> {
                val map = call.arguments<HashMap<String, Any>>()!!
                val id = map["id"] as Int?
                if (id != null) {
                    JPushInterface.clearNotificationById(activity, id)
                } else {
                    val clearLocal = map["clearLocal"] as Boolean
                    if (clearLocal) {
                        JPushInterface.clearLocalNotifications(activity)
                    } else {
                        JPushInterface.clearAllNotifications(activity)
                    }
                }
                result.success(true)
            }

            "getLaunchAppNotification" -> {
                result.success(null)
            }

            "requestPermission" -> {
                JPushInterface.requestPermission(activity)
                result.success(true)
            }

            "getRegistrationID" -> {
                result.success(JPushInterface.getRegistrationID(activity))
            }

            "sendLocalNotification" -> {
                val map = call.arguments<Map<String, Any>>()!!
                val ln = JPushLocalNotification()
                //设置本地通知样式
                ln.builderId = (map["buildId"] as Int).toLong()
                ln.notificationId = (map["id"] as Int).toLong()
                ln.title = map["title"] as String?
                ln.content = map["content"] as String?
                ln.extras = (map["extra"] as Map<*, *>?).toString()
                ln.broadcastTime = (map["fireTime"] as Int).toLong()
                JPushInterface.addLocalNotification(context, ln)
                val badge = map["badge"] as Int?
                if (badge != null) JPushInterface.setBadgeNumber(activity, badge)
                result.success(true)
            }

            "setBadge" -> {
                val badge = call.arguments as Int
                JPushInterface.setBadgeNumber(activity, badge)
                result.success(true)
            }

            "isNotificationEnabled" -> {
                val isEnabled = JPushInterface.isNotificationEnabled(activity)
                //1表示开启，0表示关闭，-1表示检测失败
                result.success(isEnabled == 1)
            }

            "isPushStopped" -> result.success(
                JPushInterface.isPushStopped(activity)
            )

            "getUdID" -> result.success(JPushInterface.getUdid(activity))
            "openSettingsForNotification" -> {
                JPushInterface.goToAppNotificationSettings(activity)
                result.success(true)
            }

            else -> result.notImplemented()

        }
    }


    class JPushService : JPushMessageService() {

        override fun onMessage(activity: Context?, message: CustomMessage?) {
            super.onMessage(activity, message)
            handle.post {
                channel.invokeMethod("onReceiveMessage", message?.toMap())
            }
        }

        override fun onNotifyMessageOpened(activity: Context?, message: NotificationMessage?) {
            super.onNotifyMessageOpened(activity, message)
            handle.post {
                channel.invokeMethod("onOpenNotification", message?.toMap())
            }
            val launch = activity!!.packageManager.getLaunchIntentForPackage(
                activity.packageName
            )
            if (launch != null) {
                launch.addCategory(Intent.CATEGORY_LAUNCHER)
                launch.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                activity.startActivity(launch)
            }
        }

        override fun onNotifyMessageArrived(activity: Context?, message: NotificationMessage?) {
            super.onNotifyMessageArrived(activity, message)
            handle.post {
                channel.invokeMethod("onReceiveNotification", message?.toMap())
            }
        }

        override fun onCommandResult(activity: Context?, message: CmdMessage?) {
            super.onCommandResult(activity, message)
            handle.post {
                channel.invokeMethod(
                    "onCommandResult", mapOf(
                        "msg" to message?.msg,
                        "errorCode" to message?.errorCode,
                        "cmd" to message?.cmd
                    )
                )
            }
        }


        override fun onNotifyMessageDismiss(activity: Context?, message: NotificationMessage?) {
            super.onNotifyMessageDismiss(activity, message)
            handle.post {
                channel.invokeMethod("onNotifyMessageDismiss", message?.toMap())
            }
        }


        override fun onNotificationSettingsCheck(activity: Context?, isOn: Boolean, source: Int) {
            super.onNotificationSettingsCheck(activity, isOn, source)
            handle.post {
                channel.invokeMethod(
                    "onNotificationSettingsCheck", mapOf(
                        "isOn" to isOn, "source" to source
                    )
                )
            }
        }


        override fun onTagOperatorResult(
            activity: Context?, jPushMessage: JPushMessage?
        ) {
            super.onTagOperatorResult(activity, jPushMessage)
            val res: MutableMap<String, Any?> = HashMap()
            res["code"] = jPushMessage?.errorCode
            if (jPushMessage?.tags != null) res["tags"] = jPushMessage.tags.toList()
            handle.post {
                channelResult?.success(res)
                channelResult = null
            }
        }

        override fun onCheckTagOperatorResult(
            activity: Context?, jPushMessage: JPushMessage?
        ) {
            super.onCheckTagOperatorResult(activity, jPushMessage)
            val res: MutableMap<String, Any?> = HashMap()
            res["code"] = jPushMessage?.errorCode
            res["isBind"] = jPushMessage?.tagCheckStateResult
            if (jPushMessage?.tags != null) res["tags"] = jPushMessage.tags.toList()
            handle.post {
                channelResult?.success(res)
                channelResult = null
            }
        }


        override fun onAliasOperatorResult(
            activity: Context?, jPushMessage: JPushMessage?
        ) {
            super.onAliasOperatorResult(activity, jPushMessage)
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

