package fl.jpush

import cn.jpush.android.api.CustomMessage
import cn.jpush.android.api.NotificationMessage


fun NotificationMessage.toMap(): Map<String, Any?> {
    return mapOf(
        "appkey" to this.appkey,
        "msgId" to this.msgId,
        "notificationContent" to this.notificationContent,
        "notificationAlertType" to this.notificationAlertType,
        "notificationTitle" to this.notificationTitle,
        "notificationSmallIcon" to this.notificationSmallIcon,
        "notificationLargeIcon" to this.notificationLargeIcon,
        "notificationExtras" to this.notificationExtras,
        "notificationStyle" to this.notificationStyle,
        "notificationNormalSmallIcon" to this.notificationNormalSmallIcon,
        "notificationBuilderId" to this.notificationBuilderId,
        "notificationBigText" to this.notificationBigText,
        "notificationBigPicPath" to this.notificationBigPicPath,
        "notificationInbox" to this.notificationInbox,
        "notificationPriority" to this.notificationPriority,
        "notificationImportance" to this.notificationImportance,
        "notificationCategory" to this.notificationCategory,
        "notificationId" to this.notificationId,
        "developerArg0" to this.developerArg0,
        "platform" to this.platform,
        "appId" to this.appId,
        "notificationType" to this.notificationType,
        "notificationChannelId" to this.notificationChannelId,
        "displayForeground" to this.displayForeground,
        "_webPagePath" to this._webPagePath,
        "showResourceList" to this.showResourceList,
        "isRichPush" to this.isRichPush,
        "richType" to this.richType,
        "deeplink" to this.deeplink,
        "failedAction" to this.failedAction,
        "failedLink" to this.failedLink,
        "targetPkgName" to this.targetPkgName,
        "sspWxAppId" to this.sspWxAppId,
        "sspWmOriginId" to this.sspWmOriginId,
        "sspWmType" to this.sspWmType,
        "isWmDeepLink" to this.isWmDeepLink,
        "inAppMsgType" to this.inAppMsgType,
        "inAppMsgShowType" to this.inAppMsgShowType,
        "inAppMsgShowPos" to this.inAppMsgShowPos,
        "inAppMsgTitle" to this.inAppMsgTitle,
        "inAppMsgContentBody" to this.inAppMsgContentBody,
        "inAppType" to this.inAppType,
        "inAppShowTarget" to this.inAppShowTarget,
        "inAppClickAction" to this.inAppClickAction,
        "inAppExtras" to this.inAppExtras,
        "notificationTargetEvent" to this.notificationTargetEvent?.toString()
    )
}

fun CustomMessage.toMap(): Map<String, Any?> {
    val map = mutableMapOf<String, Any?>()
    map["messageId"] = messageId
    map["extra"] = extra
    map["message"] = message
    map["contentType"] = contentType
    map["title"] = title
    map["senderId"] = senderId
    map["appId"] = appId
    map["platform"] = platform.toInt()
    return map
}
