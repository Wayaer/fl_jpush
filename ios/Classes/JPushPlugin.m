#import "JPushPlugin.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max

#import <UserNotifications/UserNotifications.h>

#endif

#import <JPush/JPUSHService.h>

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

@interface JPushPlugin () <JPUSHRegisterDelegate>
@end

#endif

static NSMutableArray<FlutterResult> *getRidResults;

@implementation JPushPlugin {
    NSDictionary *_launchNotification;
    NSDictionary *_completeLaunchNotification;
    BOOL _isJPushDidLogin;
    BOOL hasOnReceiveMessage;
    BOOL hasOnOpenNotification;
    BOOL hasOnReceiveNotification;
    NSInteger notificationTypes;
}

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    getRidResults = @[].mutableCopy;
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"fl_jpush"
                  binaryMessenger:[registrar messenger]];
    JPushPlugin *instance = [[JPushPlugin alloc] init];
    instance.channel = channel;

    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    notificationTypes = 0;
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];

    [defaultCenter removeObserver:self];

    [defaultCenter addObserver:self
                      selector:@selector(networkConnecting:)
                          name:kJPFNetworkIsConnectingNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];

    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJPFNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJPFNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kJPFNetworkDidReceiveMessageNotification
                        object:nil];
    return self;
}


- (void)networkConnecting:(NSNotification *)notification {
    _isJPushDidLogin = false;
}

- (void)networkRegister:(NSNotification *)notification {
    _isJPushDidLogin = false;
}

- (void)networkDidSetup:(NSNotification *)notification {
    _isJPushDidLogin = false;
}

- (void)networkDidClose:(NSNotification *)notification {
    _isJPushDidLogin = false;
}

- (void)networkDidLogin:(NSNotification *)notification {
    _isJPushDidLogin = YES;
    for (FlutterResult result in getRidResults) {
        result([JPUSHService registrationID]);
    }
    [getRidResults removeAllObjects];
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    if (hasOnReceiveMessage) {
        [_channel invokeMethod:@"onReceiveMessage" arguments:[notification userInfo]];
    }

}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {

    if ([@"setup" isEqualToString:call.method]) {
        [self setup:call];
        result(@(YES));
    } else if ([@"applyPushAuthority" isEqualToString:call.method]) {
        [self applyPushAuthority:call result:result];
    } else if ([@"setTags" isEqualToString:call.method]) {
        NSSet *tagSet;
        if (call.arguments != NULL) tagSet = [NSSet setWithArray:call.arguments];
        [JPUSHService setTags:tagSet completion:^(NSInteger code, NSSet *iTags, NSInteger seq) {
            result(@{@"tags": [iTags allObjects] ?: @[],
                    @"code": @(code)});
        }                 seq:0];
    } else if ([@"validTag" isEqualToString:call.method]) {
        NSString *tag = call.arguments;
        [JPUSHService validTag:tag completion:^(NSInteger code, NSSet *iTags, NSInteger seq, BOOL isBind) {
            result(@{@"tags": [iTags allObjects] ?: @[],
                    @"isBind": @(isBind),
                    @"code": @(code)});
        }                  seq:0];
    } else if ([@"cleanTags" isEqualToString:call.method]) {
        [JPUSHService cleanTags:^(NSInteger code, NSSet *iTags, NSInteger seq) {
            result(@{@"tags": [iTags allObjects] ?: @[],
                    @"code": @(code)});
        }                   seq:0];
    } else if ([@"addTags" isEqualToString:call.method]) {
        NSSet *tagSet;
        if (call.arguments != NULL) tagSet = [NSSet setWithArray:call.arguments];
        [JPUSHService addTags:tagSet completion:^(NSInteger code, NSSet *iTags, NSInteger seq) {
            result(@{@"tags": [iTags allObjects] ?: @[],
                    @"code": @(code)});
        }                 seq:0];
    } else if ([@"deleteTags" isEqualToString:call.method]) {
        NSSet *tagSet;
        if (call.arguments != NULL) tagSet = [NSSet setWithArray:call.arguments];
        [JPUSHService deleteTags:tagSet completion:^(NSInteger code, NSSet *iTags, NSInteger seq) {
            result(@{@"tags": [iTags allObjects] ?: @[],
                    @"code": @(code)});
        }                    seq:0];
    } else if ([@"getAllTags" isEqualToString:call.method]) {
        [JPUSHService getAllTags:^(NSInteger code, NSSet *iTags, NSInteger seq) {
            result(@{@"tags": [iTags allObjects] ?: @[],
                    @"code": @(code)});
        }                    seq:0];
    } else if ([@"getAlias" isEqualToString:call.method]) {
        [JPUSHService getAlias:^(NSInteger code, NSString *iAlias, NSInteger seq) {
            result(@{@"alias": iAlias ?: @"",
                    @"code": @(code)});
        }                  seq:0];
    } else if ([@"setAlias" isEqualToString:call.method]) {
        NSString *alias = call.arguments;
        [JPUSHService setAlias:alias completion:^(NSInteger code, NSString *iAlias, NSInteger seq) {
            result(@{@"alias": iAlias ?: @"",
                    @"code": @(code)});
        }                  seq:0];
    } else if ([@"deleteAlias" isEqualToString:call.method]) {
        [JPUSHService deleteAlias:^(NSInteger code, NSString *iAlias, NSInteger seq) {
            result(@{@"alias": iAlias ?: @"",
                    @"code": @(code)});
        }                     seq:0];
    } else if ([@"setBadge" isEqualToString:call.method]) {
        NSInteger badge = [call.arguments intValue];
        if (badge < 0) badge = 0;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
        [JPUSHService setBadge:badge];
        result(@(YES));
    } else if ([@"stopPush" isEqualToString:call.method]) {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        result(@(YES));
    } else if ([@"resumePush" isEqualToString:call.method]) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        result(@(YES));
    } else if ([@"clearNotification" isEqualToString:call.method]) {
        [self clearNotification:call result:result];
    } else if ([@"getLaunchAppNotification" isEqualToString:call.method]) {
        result(_launchNotification == nil ? @{} : _launchNotification);
    } else if ([@"getRegistrationID" isEqualToString:call.method]) {
        [self getRegistrationID:call result:result];
    } else if ([@"sendLocalNotification" isEqualToString:call.method]) {
        [self sendLocalNotification:call result:result];
    } else if ([@"isNotificationEnabled" isEqualToString:call.method]) {
        [JPUSHService requestNotificationAuthorization:^(JPAuthorizationStatus status) {
            result(@(status == JPAuthorizationStatusAuthorized));
        }];
    } else if ([@"openSettingsForNotification" isEqualToString:call.method]) {
        [JPUSHService openSettingsForNotification:^(BOOL success) {
            result(@(success));
        }];
    } else if ([@"setEventHandler" isEqualToString:call.method]) {
        hasOnReceiveMessage = [call.arguments[@"onReceiveMessage"] boolValue];
        hasOnReceiveNotification = [call.arguments[@"onReceiveNotification"] boolValue];
        hasOnOpenNotification = [call.arguments[@"onOpenNotification"] boolValue];
        result(@(YES));
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)setup:(FlutterMethodCall *)call {
    NSDictionary *arguments = call.arguments;
    NSNumber *debug = arguments[@"debug"];
    if ([debug boolValue]) {
        [JPUSHService setDebugMode];
    } else {
        [JPUSHService setLogOFF];
    }
    [JPUSHService setupWithOption:_completeLaunchNotification
                           appKey:arguments[@"appKey"]
                          channel:arguments[@"channel"]
                 apsForProduction:[arguments[@"production"] boolValue]];
}

- (void)applyPushAuthority:(FlutterMethodCall *)call result:(FlutterResult)result {
    notificationTypes = 0;
    NSDictionary *arguments = call.arguments;
    if ([arguments[@"sound"] boolValue]) {
        notificationTypes |= JPAuthorizationOptionSound;
    }
    if ([arguments[@"alert"] boolValue]) {
        notificationTypes |= JPAuthorizationOptionAlert;
    }
    if ([arguments[@"badge"] boolValue]) {
        notificationTypes |= JPAuthorizationOptionBadge;
    }
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = notificationTypes;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    result(@YES);
}


- (void)clearNotification:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSNumber *notificationId = call.arguments;
    if (@available(iOS 10.0, *)) {
        //iOS 10 以上支持
        JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
        if (notificationId) {identifier.identifiers = @[notificationId.stringValue];} else {identifier.identifiers = nil;}
        identifier.delivered = YES;  //等于 YES 则移除所有在通知中心显示的，等于 NO 则为移除所有待推送的
        [JPUSHService removeNotification:identifier];
    } else {
        // iOS 10 以下移除所有推送；iOS 10 以上移除所有在通知中心显示推送和待推送请求
        [JPUSHService removeNotification:nil];
    }
    result(@(YES));
}


- (void)getRegistrationID:(FlutterMethodCall *)call result:(FlutterResult)result {
#if TARGET_IPHONE_SIMULATOR//模拟器
    result(@"");
#elif TARGET_OS_IPHONE//真机
    if ([JPUSHService registrationID] != nil && ![[JPUSHService registrationID] isEqualToString:@""]) {
        // 如果已经成功获取 registrationID，从本地获取直接缓存
        result([JPUSHService registrationID]);
        return;
    }
    if (_isJPushDidLogin) {// 第一次获取未登录情况
        result([JPUSHService registrationID]);
    } else {
        [getRidResults addObject:result];
    }
#endif
}

- (void)sendLocalNotification:(FlutterMethodCall *)call result:(FlutterResult)result {

    JPushNotificationContent *content = [[JPushNotificationContent alloc] init];
    NSDictionary *params = call.arguments;
    if (params[@"title"]) {
        content.title = params[@"title"];
    }

    if (params[@"subtitle"]) {
        content.subtitle = params[@"subtitle"];
    }

    if (params[@"content"]) {
        content.body = params[@"content"];
    }

    if (params[@"badge"]) {
        content.badge = params[@"badge"];
    }

    if ([params[@"extra"] isKindOfClass:[NSDictionary class]]) {
        content.userInfo = params[@"extra"];
    }

    if (params[@"sound"]) {
        content.sound = params[@"sound"];
    }
    JPushNotificationTrigger *trigger = [[JPushNotificationTrigger alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        if (params[@"fireTime"]) {
            NSNumber *date = params[@"fireTime"];
            NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval interval = [date doubleValue] / 1000 - currentInterval;
            interval = interval > 0 ? interval : 0;
            trigger.timeInterval = interval;
        }
    }
    JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
    request.content = content;
    request.trigger = trigger;

    if (params[@"id"]) {
        NSNumber *identify = params[@"id"];
        request.requestIdentifier = [identify stringValue];
    }
    request.completionHandler = ^(id result) {
        NSLog(@"本地消息：%@", result);
    };
    [JPUSHService addNotification:request];
    result(@(YES));
}


- (void)dealloc {
    _isJPushDidLogin = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _completeLaunchNotification = launchOptions;
    if (launchOptions != nil) {
        _launchNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        _launchNotification = _launchNotification.copy;
    }
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}


- (BOOL)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (hasOnReceiveNotification) {
        [JPUSHService handleRemoteNotification:userInfo];
        [_channel invokeMethod:@"onReceiveNotification" arguments:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
    return YES;
}


- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)) {
    NSDictionary *userInfo = notification.request.content.userInfo;
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [_channel invokeMethod:@"onReceiveNotification" arguments:userInfo];
    }
    completionHandler(notificationTypes);
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {

    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (hasOnOpenNotification) {
        if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [_channel invokeMethod:@"onOpenNotification" arguments:userInfo];
        }
    }
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler();
}


- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(NSDictionary *)info {
    if (hasOnOpenNotification) {
        [self.channel invokeMethod:@"onReceiveNotificationAuthorization" arguments:@(status == JPAuthorizationStatusAuthorized)];

    }
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification {


}

@end
