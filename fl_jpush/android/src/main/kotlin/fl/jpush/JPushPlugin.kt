package fl.jpush

import android.annotation.SuppressLint
import android.app.Activity
import android.content.BroadcastReceiver
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
                    result.success(it.returnCode == 0)
                    if (it.returnCode == 0) {
                        JPushInterface.setChannel(
                            context, map["channel"] as String?
                        )
                    }
                }
            }

            "setTags" -> {
                val sequence = getSequence()
                val tagList = call.arguments<List<String>>()!!
                val tags: Set<String> = HashSet(tagList)
                JPushInterface.setTags(context, sequence, tags)
            }

            "validTag" -> {
                val sequence = getSequence()
                val tag = call.arguments
                JPushInterface.checkTagBindState(
                    context, sequence, tag.toString()
                )
            }

            "cleanTags" -> {
                val sequence = getSequence()
                JPushInterface.cleanTags(context, sequence)
            }

            "addTags" -> {
                val sequence = getSequence()
                val tagList = call.arguments<List<String>>()!!
                val tags: Set<String> = HashSet(tagList)
                JPushInterface.addTags(context, sequence, tags)
            }

            "deleteTags" -> {
                val sequence = getSequence()
                val tagList = call.arguments<List<String>>()!!
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

            "clearNotification" -> {
                val id = call.arguments
                if (id != null) {
                    JPushInterface.clearNotificationById(context, id as Int)
                } else {
                    JPushInterface.clearAllNotifications(context)
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
                val map = call.arguments<Map<String, Any>>()!!
                val ln = JPushLocalNotification()
                ln.builderId = (map["buildId"] as Number).toLong()
                ln.notificationId = (map["id"] as Number).toLong()
                ln.title = map["title"] as String?
                ln.content = map["content"] as String?
                ln.extras = (map["extra"] as Map<*, *>?).toString()
                ln.broadcastTime = map["fireTime"] as Long
                JPushInterface.addLocalNotification(context, ln)
                JPushInterface.setBadgeNumber(context, map["badge"] as Int)
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


            else -> result.notImplemented()

        }
    }


    class JPushService : JPushMessageService() {
        override fun onMultiActionClicked(context: Context?, intent: Intent?) {
            super.onMultiActionClicked(context, intent)
            val nActionExtra: String? =
                intent?.extras?.getString(JPushInterface.EXTRA_NOTIFICATION_ACTION_EXTRA)
            println("====onMultiActionClicked${nActionExtra}")
        }

        override fun onMessage(context: Context?, message: CustomMessage?) {
            super.onMessage(context, message)
            println("====onMessage${message?.message}")
            channel.invokeMethod(
                "onReceiveMessage", mapOf(
                    "message" to message?.message,
                    "extras" to message?.extra,
                    "messageId" to message?.messageId,
                    "contentType" to message?.contentType,
                    "title" to message?.title,
                    "senderId" to message?.senderId,
                    "appId" to message?.appId,
                    "platform" to message?.platform,
                )
            )
        }

        override fun onNotifyMessageOpened(context: Context?, message: NotificationMessage?) {
            super.onNotifyMessageOpened(context, message)
            println("====onNotifyMessageOpened${message?.notificationContent}")
            channel.invokeMethod(
                "onOpenNotification", mapOf(
                    "title" to message?.notificationTitle,
                    "alert" to message?.notificationAlertType,
                    "extras" to message?.notificationExtras,
                    "type" to message?.notificationType
                )
            )
            val launch = context!!.packageManager.getLaunchIntentForPackage(
                context.packageName
            )
            if (launch != null) {
                launch.addCategory(Intent.CATEGORY_LAUNCHER)
                launch.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                context.startActivity(launch)
            }

        }


        override fun onNotifyMessageDismiss(context: Context?, message: NotificationMessage?) {
            super.onNotifyMessageDismiss(context, message)
            println("====onNotifyMessageDismiss${message?.notificationContent}")
        }

        override fun onRegister(context: Context?, registrationId: String?) {
            super.onRegister(context, registrationId)
            println("====onRegister${registrationId}")
        }

        override fun onConnected(context: Context?, isConnected: Boolean) {
            super.onConnected(context, isConnected)
            println("====onConnected${isConnected}")
        }

        override fun onCommandResult(context: Context?, message: CmdMessage?) {
            super.onCommandResult(context, message)
            println("====onCommandResult${message?.msg}")

        }

        override fun onMobileNumberOperatorResult(context: Context?, message: JPushMessage?) {
            super.onMobileNumberOperatorResult(context, message)
            println("====onCommandResult${message?.mobileNumber}")
        }

        override fun onNotifyMessageArrived(context: Context?, message: NotificationMessage?) {
            super.onNotifyMessageArrived(context, message)
            println("====onNotifyMessageArrived${message?.notificationContent}")
        }

        override fun onNotificationSettingsCheck(context: Context?, isOn: Boolean, source: Int) {
            super.onNotificationSettingsCheck(context, isOn, source)
            println("====onNotificationSettingsCheck${isOn} ${source}")
        }


        override fun onTagOperatorResult(
            context: Context?, jPushMessage: JPushMessage?
        ) {
            super.onTagOperatorResult(context, jPushMessage)
            val res: MutableMap<String, Any?> = HashMap()
            res["code"] = jPushMessage?.errorCode
            if (jPushMessage?.tags != null) res["tags"] = jPushMessage.tags.toList()
            handle.post {
                channelResult?.success(res)
                channelResult = null
            }
        }

        override fun onCheckTagOperatorResult(
            context: Context?, jPushMessage: JPushMessage?
        ) {
            super.onCheckTagOperatorResult(context, jPushMessage)
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
            context: Context?, jPushMessage: JPushMessage?
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