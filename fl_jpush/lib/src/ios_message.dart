part of '../fl_jpush.dart';

/// ios 通知
class NotificationMessageWithIOS {
  int? msgId;
  NotificationMessageAps? aps;
  int? business;
  int? uid;
  NotificationJData? data;

  NotificationMessageWithIOS.fromMap(Map<dynamic, dynamic> map) {
    msgId = map['_j_msgid'] as int?;
    aps =
        map['aps'] == null ? null : NotificationMessageAps.fromMap(map['aps']);
    business = map['_j_business'] as int?;
    uid = map['_j_uid'] as int?;
    try {
      data = map['_j_data_'] == null
          ? null
          : NotificationJData.fromMap(jsonDecode(map['_j_data_']));
    } catch (e) {
      debugPrint('NotificationMessageWithIOS data jsonDecode');
    }
  }

  Map<String, dynamic> toMap() => {
        'msgId': msgId,
        'aps': aps?.toMap(),
        'business': business,
        'uid': uid,
        'data': data?.toMap()
      };
}

class NotificationMessageAps {
  int? mutableContent;
  String? threadId;
  int? badge;
  String? sound;
  String? filterCriteria;
  String? interruptionLevel;
  int? contentAvailable;
  NotificationMessageAlert? alert;

  NotificationMessageAps.fromMap(Map<dynamic, dynamic> map) {
    mutableContent = map['mutable-content'] as int?;
    threadId = map['thread-id'] as String?;
    badge = map['badge'] as int?;
    sound = map['sound'] as String?;
    filterCriteria = map['filter-criteria'] as String?;
    interruptionLevel = map['interruption-level'] as String?;
    contentAvailable = map['content-available'] as int?;
    alert = map['alert'] == null
        ? null
        : NotificationMessageAlert.fromMap(map['alert']);
  }

  Map<String, dynamic> toMap() => {
        'mutableContent': mutableContent,
        'threadId': threadId,
        'badge': badge,
        'sound': sound,
        'filterCriteria': filterCriteria,
        'interruptionLevel': interruptionLevel,
        'contentAvailable': contentAvailable,
        'alert': alert?.toMap(),
      };
}

class NotificationMessageAlert {
  String? subtitle;
  String? title;
  String? body;

  NotificationMessageAlert.fromMap(Map<dynamic, dynamic> map) {
    subtitle = map['subtitle'] as String?;
    title = map['title'] as String?;
    body = map['body'] as String?;
  }

  Map<String, dynamic> toMap() =>
      {'subtitle': subtitle, 'title': title, 'body': body};
}

class NotificationJData {
  int? dataMsgType;
  int? pushType;
  int? isVip;

  NotificationJData.fromMap(Map<dynamic, dynamic> map) {
    dataMsgType = map['data_msgtype'] as int?;
    pushType = map['push_type'] as int?;
    isVip = map['is_vip'] as int?;
  }

  Map<String, dynamic> toMap() =>
      {'dataMsgType': dataMsgType, 'pushType': pushType, 'isVip': isVip};
}

class CustomMessageWithIOS {
  String? msgId;
  String? content;
  Map<dynamic, dynamic>? extra;

  CustomMessageWithIOS.fromMap(Map<dynamic, dynamic> map) {
    msgId = map['_j_msgid'] as String?;
    content = map['content'] as String?;
    extra = map['extra'] as Map<dynamic, dynamic>?;
  }

  Map<String, dynamic> toMap() =>
      {'msgId': msgId, 'content': content, 'extra': extra};
}
