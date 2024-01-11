part of '../fl_jpush.dart';

/// android 通知
class NotificationMessageWithAndroid {
  String? appKey;
  String? msgId;
  String? notificationContent;
  int? notificationAlertType;
  String? notificationTitle;
  String? notificationSmallIcon;
  String? notificationLargeIcon;
  String? notificationExtras;
  int? notificationStyle;
  String? notificationNormalSmallIcon;
  int? notificationBuilderId;
  String? notificationBigText;
  String? notificationBigPicPath;
  String? notificationInbox;
  int? notificationPriority;
  int? notificationImportance;
  String? notificationCategory;
  int? notificationId;
  String? developerArg0;
  int? platform = 0;
  String? appId;
  int? notificationType;
  String? notificationChannelId;
  String? displayForeground;
  String? webPagePath;
  List<dynamic>? showResourceList;
  bool? isRichPush;
  int? richType;
  String? deeplink;
  int? failedAction;
  String? failedLink;
  String? targetPkgName;
  String? sspWxAppId;
  String? sspWmOriginId;
  int? sspWmType;
  bool? isWmDeepLink;
  int? inAppMsgType;
  int? inAppMsgShowType;
  int? inAppMsgShowPos;
  String? inAppMsgTitle;
  String? inAppMsgContentBody;
  int? inAppType;
  String? inAppShowTarget;
  String? inAppClickAction;
  String? inAppExtras;
  String? notificationTargetEvent;

  NotificationMessageWithAndroid.fromMap(Map<dynamic, dynamic> map) {
    appKey = map['appkey'] as String?;
    msgId = map['msgId'] as String?;
    notificationContent = map['notificationContent'] as String?;
    notificationAlertType = map['notificationAlertType'] as int?;
    notificationTitle = map['notificationTitle'] as String?;
    notificationSmallIcon = map['notificationSmallIcon'] as String?;
    notificationLargeIcon = map['notificationLargeIcon'] as String?;
    notificationExtras = map['notificationExtras'] as String?;
    notificationStyle = map['notificationStyle'] as int?;
    notificationNormalSmallIcon = map['notificationNormalSmallIcon'] as String?;
    notificationBuilderId = map['notificationBuilderId'] as int?;
    notificationBigText = map['notificationBigText'] as String?;
    notificationBigPicPath = map['notificationBigPicPath'] as String?;
    notificationInbox = map['notificationInbox'] as String?;
    notificationPriority = map['notificationPriority'] as int?;
    notificationImportance = map['notificationImportance'] as int?;
    notificationCategory = map['notificationCategory'] as String?;
    notificationId = map['notificationId'] as int?;
    developerArg0 = map['developerArg0'] as String?;
    platform = map['platform'] as int?;
    appId = map['appId'] as String?;
    notificationType = map['notificationType'] as int?;
    notificationChannelId = map['notificationChannelId'] as String?;
    displayForeground = map['displayForeground'] as String?;
    webPagePath = map['_webPagePath'] as String?;
    showResourceList = map['showResourceList'] as List<dynamic>?;
    isRichPush = map['isRichPush'] as bool?;
    richType = map['richType'] as int?;
    deeplink = map['deeplink'] as String?;
    failedAction = map['failedAction'] as int?;
    failedLink = map['failedLink'] as String?;
    targetPkgName = map['targetPkgName'] as String?;
    sspWxAppId = map['sspWxAppId'] as String?;
    sspWmOriginId = map['sspWmOriginId'] as String?;
    sspWmType = map['sspWmType'] as int?;
    isWmDeepLink = map['isWmDeepLink'] as bool?;
    inAppMsgType = map['inAppMsgType'] as int?;
    inAppMsgShowType = map['inAppMsgShowType'] as int?;
    inAppMsgShowPos = map['inAppMsgShowPos'] as int?;
    inAppMsgTitle = map['inAppMsgTitle'] as String?;
    inAppMsgContentBody = map['inAppMsgContentBody'] as String?;
    inAppType = map['inAppType'] as int?;
    inAppShowTarget = map['inAppShowTarget'] as String?;
    inAppClickAction = map['inAppClickAction'] as String?;
    inAppExtras = map['inAppExtras'] as String?;
    notificationTargetEvent = map['notificationTargetEvent'] as String?;
  }

  Map<String, dynamic> toMap() => {
        'appkey': appKey,
        'msgId': msgId,
        'notificationContent': notificationContent,
        'notificationAlertType': notificationAlertType,
        'notificationTitle': notificationTitle,
        'notificationSmallIcon': notificationSmallIcon,
        'notificationLargeIcon': notificationLargeIcon,
        'notificationExtras': notificationExtras,
        'notificationStyle': notificationStyle,
        'notificationNormalSmallIcon': notificationNormalSmallIcon,
        'notificationBuilderId': notificationBuilderId,
        'notificationBigText': notificationBigText,
        'notificationBigPicPath': notificationBigPicPath,
        'notificationInbox': notificationInbox,
        'notificationPriority': notificationPriority,
        'notificationImportance': notificationImportance,
        'notificationCategory': notificationCategory,
        'notificationId': notificationId,
        'developerArg0': developerArg0,
        'platform': platform,
        'appId': appId,
        'notificationType': notificationType,
        'notificationChannelId': notificationChannelId,
        'displayForeground': displayForeground,
        '_webPagePath': webPagePath,
        'showResourceList': showResourceList,
        'isRichPush': isRichPush,
        'richType': richType,
        'deeplink': deeplink,
        'failedAction': failedAction,
        'failedLink': failedLink,
        'targetPkgName': targetPkgName,
        'sspWxAppId': sspWxAppId,
        'sspWmOriginId': sspWmOriginId,
        'sspWmType': sspWmType,
        'isWmDeepLink': isWmDeepLink,
        'inAppMsgType': inAppMsgType,
        'inAppMsgShowType': inAppMsgShowType,
        'inAppMsgShowPos': inAppMsgShowPos,
        'inAppMsgTitle': inAppMsgTitle,
        'inAppMsgContentBody': inAppMsgContentBody,
        'inAppType': inAppType,
        'inAppShowTarget': inAppShowTarget,
        'inAppClickAction': inAppClickAction,
        'inAppExtras': inAppExtras,
        'notificationTargetEvent': notificationTargetEvent,
      };
}

class CustomMessageWithAndroid {
  String? messageId;
  String? extra;
  String? message;
  String? contentType;
  String? title;
  String? senderId;
  String? appId;
  int? platform;

  CustomMessageWithAndroid.fromMap(Map<dynamic, dynamic> map) {
    messageId = map['messageId'] as String?;
    extra = map['extra'] as String?;
    message = map['message'] as String?;
    contentType = map['contentType'] as String?;
    title = map['title'] as String?;
    senderId = map['senderId'] as String?;
    appId = map['appId'] as String?;
    platform = map['platform'] as int?;
  }

  Map<String, dynamic> toMap() => {
        'messageId': messageId,
        'extra': extra,
        'message': message,
        'contentType': contentType,
        'title': title,
        'senderId': senderId,
        'appId': appId,
        'platform': platform,
      };
}
