import Flutter
import Foundation

public class JPushPlugin: NSObject, FlutterPlugin, JPUSHRegisterDelegate {
    private var registrar: FlutterPluginRegistrar
    private var channel: FlutterMethodChannel
    
    private var launchNotification: [AnyHashable: Any]?
    private var completeLaunchNotification: [AnyHashable: Any] = [:]
    private var isJPushDidLogin = false
    private var notificationTypes: Int = 0
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fl_jpush", binaryMessenger: registrar.messenger())
        let instance = JPushPlugin(registrar, channel)
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(_ registrar: FlutterPluginRegistrar, _ channel: FlutterMethodChannel) {
        self.registrar = registrar
        self.channel = channel
        super.init()
        notificationTypes = 0
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
        notificationCenter.addObserver(self, selector: #selector(networkDidNotLogin), name: NSNotification.Name.jpfNetworkIsConnecting, object: nil)
        notificationCenter.addObserver(self, selector: #selector(networkDidNotLogin), name: NSNotification.Name.jpfNetworkDidRegister, object: nil)
        notificationCenter.addObserver(self, selector: #selector(networkDidNotLogin), name: NSNotification.Name.jpfNetworkDidClose, object: nil)
        notificationCenter.addObserver(self, selector: #selector(networkDidNotLogin), name: NSNotification.Name.jpfNetworkDidSetup, object: nil)
        notificationCenter.addObserver(self, selector: #selector(networkDidLogin), name: NSNotification.Name.jpfNetworkDidLogin, object: nil)
        notificationCenter.addObserver(self, selector: #selector(networkDidReceiveMessage), name: NSNotification.Name.jpfNetworkDidReceiveMessage, object: nil)
    }
    
    @objc func networkDidNotLogin(notification: NSNotification) {
        isJPushDidLogin = false
    }

    @objc func networkDidLogin(notification: NSNotification) {
        isJPushDidLogin = true
    }

    @objc func networkDidReceiveMessage(notification: NSNotification) {
        channel.invokeMethod("onReceiveMessage", arguments: notification.userInfo)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setup":
            let args = call.arguments as! [String: Any?]
            setup(args)
            result(true)
        case "applyPushAuthority":
            let args = call.arguments as! [String: Any?]
            applyPushAuthority(args)
            result(true)
        case "setTags":
            let args = call.arguments as! [String]
            JPUSHService.setTags(Set(args), completion: { code, tags, _ in
                result(["tags": Array(tags ?? []) as Any,
                        "code": code])
            }, seq: 0)
        case "validTag":
            let args = call.arguments as! String
            JPUSHService.validTag(args, completion: { code, tags, _, isBind in
                result(["tags": Array(tags ?? []) as Any,
                        "isBind": isBind,
                        "code": code])
            }, seq: 0)
        case "cleanTags":
            JPUSHService.cleanTags({ code, tags, _ in
                result(["tags": Array(tags ?? []) as Any,
                        "code": code])
            }, seq: 0)
        case "deleteTags":
            let args = call.arguments as! [String]
            JPUSHService.deleteTags(Set(args), completion: { code, tags, _ in
                result(["tags": Array(tags ?? []) as Any,
                        "code": code])
            }, seq: 0)
        case "addTags":
            let args = call.arguments as! [String]
            JPUSHService.addTags(Set(args), completion: { code, tags, _ in
                result(["tags": Array(tags ?? []) as Any,
                        "code": code])
            }, seq: 0)
        case "getAllTags":
            JPUSHService.getAllTags({ code, tags, _ in
                result(["tags": Array(tags ?? []) as Any,
                        "code": code])
            }, seq: 0)
        case "getAlias":
            JPUSHService.getAlias({ code, alias, _ in
                result(["alias": alias as Any,
                        "code": code])
            }, seq: 0)
        case "setAlias":
            let args = call.arguments as! String
            JPUSHService.setAlias(args, completion: { code, alias, _ in
                result(["alias": alias as Any,
                        "code": code])
            }, seq: 0)
        case "deleteAlias":
            JPUSHService.deleteAlias({ code, alias, _ in
                result(["alias": alias as Any,
                        "code": code])
            }, seq: 0)
            
        case "setBadge":
            let badge = call.arguments as! Int
            UIApplication.shared.applicationIconBadgeNumber = badge
            JPUSHService.setBadge(badge)
            result(true)
        case "stopPush":
            UIApplication.shared.unregisterForRemoteNotifications()
            result(true)
        case "resumePush":
            UIApplication.shared.registerForRemoteNotifications()
            result(true)
        case "clearNotification":
            let args = call.arguments as! [String: Any?]
            let notificationId = args["id"] as? Int
            let identifier = JPushNotificationIdentifier()
            if notificationId != nil {
                identifier.identifiers = ["\(notificationId!)"]
            } else {
                identifier.identifiers = nil
            }
            identifier.delivered = args["delivered"] as! Bool
            JPUSHService.removeNotification(identifier)
            result(true)
        case "getLaunchAppNotification":
            result(launchNotification)
        case "getRegistrationID":
            result(JPUSHService.registrationID())
        case "openSettingsForNotification":
            JPUSHService.openSettings { success in
                result(success)
            }
        case "isNotificationEnabled":
            JPUSHService.requestNotificationAuthorization { status in
                result(status == JPAuthorizationStatus.statusAuthorized)
            }
        case "sendLocalNotification":
            let args = call.arguments as! [String: Any?]
            sendLocalNotification(args)
            result(true)
        default:
            result(nil)
        }
    }

    public func sendLocalNotification(_ args: [String: Any?]) {
        let content = JPushNotificationContent()
        content.title = args["title"] as! String
        content.subtitle = args["subtitle"] as! String
        content.body = args["content"] as! String
        content.sound = args["sound"] as? String
        if let badge = args["badge"] as? Int {
            content.badge = NSNumber(value: badge)
        }
        content.userInfo = args["extra"] as! [AnyHashable: Any]
        let trigger = JPushNotificationTrigger()
        trigger.timeInterval = TimeInterval(args["fireTime"] as! Int)
        let request = JPushNotificationRequest()
        request.content = content
        request.trigger = trigger
        request.requestIdentifier = String(args["id"] as! Int)
        request.completionHandler = { result in
            print("本地消息推送结果(null为失败): \(result)")
        }
        JPUSHService.addNotification(request)
    }

    public func applyPushAuthority(_ args: [String: Any?]) {
        notificationTypes = 0
        if args["alert"] as! Bool {
            notificationTypes |= Int(JPAuthorizationOptions.sound.rawValue)
        }
        if args["sound"] as! Bool {
            notificationTypes |= Int(JPAuthorizationOptions.alert.rawValue)
        }
        if args["badge"] as! Bool {
            notificationTypes |= Int(JPAuthorizationOptions.badge.rawValue)
        }
       
        if #available(iOS 13.0, *), args["announcement"] as! Bool {
            notificationTypes |= Int(JPAuthorizationOptions.announcement.rawValue)
        }
        if #available(iOS 12.0, *) {
            if args["provisional"] as! Bool {
                notificationTypes |= Int(JPAuthorizationOptions.provisional.rawValue)
            }
            if args["providesAppNotificationSettings"] as! Bool {
                notificationTypes |= Int(JPAuthorizationOptions.providesAppNotificationSettings.rawValue)
            }
        }
        if args["carPlay"] as! Bool {
            notificationTypes |= Int(JPAuthorizationOptions.carPlay.rawValue)
        }
        let entity = JPUSHRegisterEntity()
        entity.types = notificationTypes
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
    }
    
    public func setup(_ args: [String: Any?]) {
        let debug = args["debug"] as! Bool
        
        if debug {
            JPUSHService.setDebugMode()
        } else {
            JPUSHService.setLogOFF()
        }
        JPUSHService.setup(withOption: completeLaunchNotification, appKey: args["appKey"] as! String, channel: args["channel"] as? String, apsForProduction: args["production"] as! Bool)
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]) -> Bool {
        completeLaunchNotification = launchOptions
        launchNotification = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
        return true
    }
    
    public func jpushNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (Int) -> Void) {
        let userInfo = notification.request.content.userInfo
        JPUSHService.handleRemoteNotification(userInfo)
        channel.invokeMethod("onReceiveNotification", arguments: userInfo)
        completionHandler(notificationTypes)
    }

    public func jpushNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        channel.invokeMethod("onOpenNotification", arguments: userInfo)
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler()
    }
    
    public func jpushNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification) {
        channel.invokeMethod("onOpenSettingsForNotification", arguments: notification.request.content.userInfo)
    }
    
    public func jpushNotificationAuthorization(_ status: JPAuthorizationStatus, withInfo info: [AnyHashable: Any]?) {
        channel.invokeMethod("onReceiveNotificationAuthorization", arguments: status == JPAuthorizationStatus.statusAuthorized)
    }
    
    deinit {
        isJPushDidLogin = false
        NotificationCenter.default.removeObserver(self)
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
}
