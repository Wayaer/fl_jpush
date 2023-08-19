#import "FlJVerifyPlugin.h"
#import "JVERIFICATIONService.h"
// 如果需要使用 idfa 功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>

#define UIColorFromRGB(rgbValue)  ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

@implementation FlJVerifyPlugin


/// 错误码
static NSString *const codeKey = @"code";
/// 回调的提示信息，统一返回 flutter 为 message
static NSString *const msgKey = @"message";
/// 运营商信息
static NSString *const operatorKey = @"operator";

static BOOL needStartAnim = FALSE;
static BOOL needCloseAnim = FALSE;

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"fl_jverify"
                  binaryMessenger:[registrar messenger]];
    FlJVerifyPlugin *instance = [[FlJVerifyPlugin alloc] init];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"setup" isEqualToString:call.method]) {
        NSDictionary *arguments = [call arguments];
        NSString *iosKey = arguments[@"iosKey"];
        NSString *channel = arguments[@"channel"];
        NSNumber *useIDFA = arguments[@"useIDFA"];
        NSNumber *timeout = arguments[@"timeout"];
        JVAuthConfig *config = [[JVAuthConfig alloc] init];
        config.appKey = iosKey;
        if (![channel isKindOfClass:[NSNull class]]) {
            config.channel = channel;
        }
        if ([timeout isKindOfClass:[NSNull class]]) {
            timeout = @(10000);
        }
        config.timeout = [timeout longLongValue];
        NSString *idfaStr = NULL;
        if ([useIDFA boolValue]) {
            idfaStr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            config.advertisingId = idfaStr;
        }
        config.authBlock = ^(NSDictionary *dic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(@{codeKey: dic[@"code"], msgKey: dic[@"content"]});
            });
        };
        [JVERIFICATIONService setupWithConfig:config];
    } else if ([@"setDebugMode" isEqualToString:call.method]) {
        [JVERIFICATIONService setDebug:[call.arguments boolValue]];
        result(@(YES));
    } else if ([@"isInitSuccess" isEqualToString:call.method]) {
        result(@([JVERIFICATIONService isSetupClient]));
    } else if ([@"checkVerifyEnable" isEqualToString:call.method]) {
        result(@([JVERIFICATIONService checkVerifyEnable]));
    } else if ([@"getToken" isEqualToString:call.method]) {
        [JVERIFICATIONService getToken:[call.arguments longLongValue] completion:^(NSDictionary *dic) {
            NSString *content = @"";
            if (dic[@"token"]) {
                content = dic[@"token"];
            } else if (dic[@"content"]) {
                content = dic[@"content"];
            }
            result(@{
                    codeKey: dic[@"code"],
                    msgKey: content,
                    operatorKey: dic[@"operator"] ?: @""
            });
        }];
    } else if ([@"preLogin" isEqualToString:call.method]) {
        [JVERIFICATIONService preLogin:[call.arguments longLongValue] completion:^(NSDictionary *dic) {
            result(@{
                    codeKey: dic[@"code"],
                    msgKey: dic[@"message"] ? dic[@"message"] : @""}
            );
        }];
    } else if ([@"loginAuth" isEqualToString:call.method]) {
        NSDictionary *arguments = [call arguments];
        NSNumber *hide = arguments[@"autoDismiss"];
        NSTimeInterval timeout = [arguments[@"timeout"] longLongValue];
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        __weak typeof(self) weakSelf = self;
        [JVERIFICATIONService getAuthorizationWithController:vc hide:[hide boolValue] animated:needStartAnim timeout:timeout completion:^(NSDictionary *dic) {
            NSString *content = @"";
            if (dic[@"loginToken"]) {
                content = dic[@"loginToken"];
            } else if (dic[@"content"]) {
                content = dic[@"content"];
            }
            result(@{codeKey: dic[@"code"],
                    msgKey: content,
                    operatorKey: dic[@"operator"] ?: @""
            });
        }                                        actionBlock:^(NSInteger type, NSString *content) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.channel invokeMethod:@"onReceiveAuthPageEvent" arguments:@{
                        codeKey: @(type),
                        msgKey: content ?: @""
                }];
            });
        }];
    } else if ([@"setCustomAuthorizationView" isEqualToString:call.method]) {
        NSDictionary *portraitConfig = call.arguments[@"portraitConfig"];
        NSArray *widgets = call.arguments[@"widgets"];
        JVUIConfig *config = [[JVUIConfig alloc] init];
        config.autoLayout = YES;
        config.shouldAutorotate = [[self getValue:portraitConfig key:@"isAutorotate"] boolValue];
        [self setCustomUIWithUIConfig:config configArguments:portraitConfig];
        [JVERIFICATIONService customUIWithConfig:config customViews:^(UIView *customAreaView) {
            for (NSDictionary *widgetDic in widgets) {
                NSString *type = [self getValue:widgetDic key:@"type"];
                if ([type isEqualToString:@"textView"]) {
                    [customAreaView addSubview:[self addCustomTextWidget:widgetDic]];
                } else if ([type isEqualToString:@"button"]) {
                    [customAreaView addSubview:[self addCustomButtonWidget:widgetDic]];
                } else {

                }
            }
        }];
        result(@(YES));
    } else if ([@"dismissLoginAuthPage" isEqualToString:call.method]) {
        [JVERIFICATIONService dismissLoginControllerAnimated:needCloseAnim completion:^{
            result(@(YES));
        }];
    } else if ([@"clearPreLoginCache" isEqualToString:call.method]) {
        [JVERIFICATIONService clearPreLoginCache];
        result(@(YES));
    } else if ([@"getSMSCode" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        NSString *phone = arguments[@"phone"];
        NSString *singId = arguments[@"signId"];
        NSString *tempId = arguments[@"tempId"];
        [JVERIFICATIONService getSMSCode:phone templateID:tempId signID:singId completionHandler:^(NSDictionary *_Nonnull dic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSNumber *code = dic[@"code"];
                NSString *msg = dic[@"msg"];
                NSString *uuid = dic[@"uuid"];
                if ([code intValue] == 3000) {
                    result(@{@"code": code, @"message": msg, @"result": uuid});
                } else {
                    result(@{@"code": code, @"message": msg});
                }
            });
        }];
    } else if ([@"setSmsIntervalTime" isEqualToString:call.method]) {
        [JVERIFICATIONService setGetCodeInternal:[call.arguments intValue]];
        result(@(YES));
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - 自定义授权页面原有的 UI 控件

JVLayoutConstraint *JVLayoutTop(CGFloat top, JVLayoutItem toItem, NSLayoutAttribute attr2) {
    return [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:toItem attribute:attr2 multiplier:1 constant:top];
}

JVLayoutConstraint *JVLayoutLeft(CGFloat left, JVLayoutItem toItem, NSLayoutAttribute attr2) {
    return [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:toItem attribute:attr2 multiplier:1 constant:left];
}

JVLayoutConstraint *JVLayoutRight(CGFloat right, JVLayoutItem toItem, NSLayoutAttribute attr2) {
    return [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:toItem attribute:attr2 multiplier:1 constant:right];
}

JVLayoutConstraint *JVLayoutCenterX(CGFloat centerX) {
    return [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeCenterX multiplier:1 constant:centerX];
}

JVLayoutConstraint *JVLayoutWidth(CGFloat width) {
    return [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeWidth multiplier:1 constant:width];
}

JVLayoutConstraint *JVLayoutHeight(CGFloat height) {
    return [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeHeight multiplier:1 constant:height];
}

//自定义授权页面原有的 UI 控件
- (void)setCustomUIWithUIConfig:(JVUIConfig *)uiConfig configArguments:(NSDictionary *)config {
    NSString *authStatusBarStyle = config[@"authStatusBarStyle"];
    NSString *privacyStatusBarStyle = config[@"privacyStatusBarStyle"];
    uiConfig.preferredStatusBarStyle = [self getStatusBarStyle:authStatusBarStyle];
    uiConfig.agreementPreferredStatusBarStyle = [self getStatusBarStyle:privacyStatusBarStyle];
    uiConfig.dismissAnimationFlag = needCloseAnim;
    if ([[config allKeys] containsObject:@"authBGVideoPath"] && [[config allKeys] containsObject:@"authBGVideoImgPath"]) {
        [uiConfig setVideoBackgroudResource:config[@"authBGVideoPath"] placeHolder:config[@"authBGVideoImgPath"]];
    }
    if ([[config allKeys] containsObject:@"authBGGifPath"]) {
        NSString *gitPath = [[NSBundle mainBundle] pathForResource:config[@"authBGGifPath"] ofType:@"gif"];
        if (gitPath) {
            uiConfig.authPageGifImagePath = gitPath;
        }
    }
    /************** 弹出方式 ***************/
    UIModalTransitionStyle transitionStyle = [self getTransitionStyle:[self getValue:config key:@"modelTransitionStyle"]];
    uiConfig.modalTransitionStyle = transitionStyle;
    /************** 背景 ***************/
    NSString *authBackgroundImage = config[@"authBackgroundImage"];
    authBackgroundImage = authBackgroundImage ?: nil;
    if (authBackgroundImage) {
        uiConfig.authPageBackgroundImage = [UIImage imageNamed:authBackgroundImage];
    }

    needStartAnim = [[self getValue:config key:@"needStartAnim"] boolValue];
    needCloseAnim = [[self getValue:config key:@"needCloseAnim"] boolValue];


    /************** 导航栏 ***************/
    NSNumber *navHidden = [self getValue:config key:@"navHidden"];
    if (navHidden) {
        uiConfig.navCustom = [navHidden boolValue];
    }
    NSNumber *navReturnBtnHidden = [self getValue:config key:@"navReturnBtnHidden"];
    if (navReturnBtnHidden) {
        uiConfig.navReturnHidden = [navReturnBtnHidden boolValue];
    }

    NSNumber *navColor = [self getValue:config key:@"navColor"];
    if (navColor) {
        uiConfig.navColor = UIColorFromRGB([navColor intValue]);
    }

    NSString *navText = [self getValue:config key:@"navText"];

    UIColor *navTextColor = UIColorFromRGB(-1);
    if ([self getValue:config key:@"navTextColor"]) {
        navTextColor = UIColorFromRGB([[self getValue:config key:@"navTextColor"] intValue]);
    }
    NSDictionary *navTextAttr = @{NSForegroundColorAttributeName: navTextColor};
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:navText attributes:navTextAttr];
    uiConfig.navText = attr;

    NSString *imageName = [self getValue:config key:@"navReturnImgPath"];
    if (imageName) {
        uiConfig.navReturnImg = [UIImage imageNamed:imageName];
    }
    NSNumber *navTransparent = [self getValue:config key:@"navTransparent"];
    if (navTransparent) {
        uiConfig.navTransparent = [navTransparent boolValue];
    }
    uiConfig.navReturnHidden = NO;

    /************** logo ***************/
    JVLayoutItem logoLayoutItem = [self getLayoutItem:[self getValue:config key:@"logoVerticalLayout"]];
    NSNumber *logoWidth = [self getNumberValue:config key:@"logoWidth"];
    NSNumber *logoHeight = [self getNumberValue:config key:@"logoHeight"];
    NSNumber *logoOffsetX = [self getNumberValue:config key:@"logoOffsetX"];
    NSNumber *logoOffsetY = [self getNumberValue:config key:@"logoOffsetY"];

    JVLayoutConstraint *logo_cons_x = JVLayoutCenterX([logoOffsetX floatValue]);
    JVLayoutConstraint *logo_cons_y = JVLayoutTop([logoOffsetY floatValue], logoLayoutItem, NSLayoutAttributeTop);
    JVLayoutConstraint *logo_cons_w = JVLayoutWidth([logoWidth floatValue]);
    JVLayoutConstraint *logo_cons_h = JVLayoutHeight([logoHeight floatValue]);
    uiConfig.logoConstraints = @[logo_cons_x, logo_cons_y, logo_cons_w, logo_cons_h];
    uiConfig.logoHorizontalConstraints = uiConfig.logoConstraints;

    NSString *logoImgPath = [self getValue:config key:@"logoImgPath"];
    if (logoImgPath) {
        uiConfig.logoImg = [UIImage imageNamed:logoImgPath];
    }

    NSNumber *logoHidden = [self getValue:config key:@"logoHidden"];
    if (logoHidden) {
        uiConfig.logoHidden = [logoHidden boolValue];
    }

    /************** num ***************/
    JVLayoutItem numberLayoutItem = [self getLayoutItem:[self getValue:config key:@"numberVerticalLayout"]];
    NSNumber *numFieldOffsetX = [self getNumberValue:config key:@"numFieldOffsetX"];
    NSNumber *numFieldOffsetY = [self getNumberValue:config key:@"numFieldOffsetY"];
    NSNumber *numberFieldWidth = [self getNumberValue:config key:@"numberFieldWidth"];
    NSNumber *numberFieldHeight = [self getNumberValue:config key:@"numberFieldHeight"];

    JVLayoutConstraint *num_cons_x = JVLayoutCenterX([numFieldOffsetX floatValue]);
    JVLayoutConstraint *num_cons_y = JVLayoutTop([numFieldOffsetY floatValue], numberLayoutItem, NSLayoutAttributeBottom);
    JVLayoutConstraint *num_cons_w = JVLayoutWidth([numberFieldWidth floatValue]);
    JVLayoutConstraint *num_cons_h = JVLayoutHeight([numberFieldHeight floatValue]);

    uiConfig.numberConstraints = @[num_cons_x, num_cons_y, num_cons_w, num_cons_h];
    uiConfig.numberHorizontalConstraints = uiConfig.numberConstraints;

    NSNumber *numberColor = [self getValue:config key:@"numberColor"];
    if (numberColor) {
        uiConfig.numberColor = UIColorFromRGB([numberColor intValue]);
    }

    NSNumber *numberSize = [self getValue:config key:@"numberSize"];
    if (numberSize) {
        uiConfig.numberFont = [UIFont systemFontOfSize:[numberSize floatValue]];
    }

    /************** slogan ***************/
    JVLayoutItem sloganLayoutItem = [self getLayoutItem:[self getValue:config key:@"sloganVerticalLayout"]];
    NSNumber *sloganOffsetX = [self getNumberValue:config key:@"sloganOffsetX"];
    NSNumber *sloganOffsetY = [self getNumberValue:config key:@"sloganOffsetY"];
    NSNumber *sloganWidth = [self getNumberValue:config key:@"sloganWidth"];
    NSNumber *sloganHeight = [self getNumberValue:config key:@"sloganHeight"];


    JVLayoutConstraint *slogan_cons_top = JVLayoutTop([sloganOffsetY floatValue], sloganLayoutItem, NSLayoutAttributeBottom);
    JVLayoutConstraint *slogan_cons_center_x = JVLayoutCenterX([sloganOffsetX floatValue]);
    CGFloat sloganH = [sloganHeight floatValue] > 0 ?: 20;
    CGFloat sloganW = [sloganWidth floatValue] > 0 ?: 200;
    JVLayoutConstraint *slogan_cons_width = JVLayoutWidth(sloganW);
    JVLayoutConstraint *slogan_cons_height = JVLayoutHeight(sloganH);
    uiConfig.sloganConstraints = @[slogan_cons_top, slogan_cons_center_x, slogan_cons_width, slogan_cons_height];
    uiConfig.sloganHorizontalConstraints = uiConfig.sloganConstraints;

    NSNumber *sloganTextColor = [self getValue:config key:@"sloganTextColor"];
    if (sloganTextColor) {
        uiConfig.sloganTextColor = UIColorFromRGB([sloganTextColor integerValue]);
    }

    NSNumber *sloganTextSize = [self getValue:config key:@"sloganTextSize"];
    if (sloganTextSize) {
        uiConfig.sloganFont = [UIFont systemFontOfSize:[sloganTextSize floatValue]];
    }
    /************** login btn ***************/
    JVLayoutItem loginButtonLayoutItem = [self getLayoutItem:[self getValue:config key:@"loginButtonVerticalLayout"]];
    NSNumber *loginButtonOffsetX = [self getNumberValue:config key:@"loginButtonOffsetX"];
    NSNumber *loginButtonOffsetY = [self getNumberValue:config key:@"loginButtonOffsetY"];
    NSNumber *loginButtonWidth = [self getNumberValue:config key:@"loginButtonWidth"];
    NSNumber *loginButtonHeight = [self getNumberValue:config key:@"loginButtonHeight"];

    JVLayoutConstraint *logoBtn_cons_x = JVLayoutCenterX([loginButtonOffsetX floatValue]);
    JVLayoutConstraint *logoBtn_cons_y = JVLayoutTop([loginButtonOffsetY floatValue], loginButtonLayoutItem, NSLayoutAttributeBottom);
    JVLayoutConstraint *logoBtn_cons_w = JVLayoutWidth([loginButtonWidth floatValue]);
    JVLayoutConstraint *logoBtn_cons_h = JVLayoutHeight([loginButtonHeight floatValue]);

    uiConfig.logBtnConstraints = @[logoBtn_cons_x, logoBtn_cons_y, logoBtn_cons_w, logoBtn_cons_h];
    uiConfig.logBtnHorizontalConstraints = uiConfig.logBtnConstraints;

    NSString *loginButtonText = [self getValue:config key:@"loginButtonText"];
    if (loginButtonText) {
        uiConfig.logBtnText = loginButtonText;
    }
    NSNumber *loginButtonTextSize = [self getValue:config key:@"loginButtonTextSize"];
    if (loginButtonTextSize) {
        uiConfig.logBtnFont = [UIFont systemFontOfSize:[loginButtonTextSize floatValue]];
    }
    NSNumber *loginButtonTextColor = [self getValue:config key:@"loginButtonTextColor"];
    if (loginButtonTextColor) {
        uiConfig.logBtnTextColor = UIColorFromRGB([loginButtonTextColor integerValue]);
    }
    NSString *loginBtnNormalImage = config[@"loginBtnNormalImage"];
    NSString *loginBtnPressedImage = config[@"loginBtnPressedImage"];
    NSString *loginBtnUnableImage = config[@"loginBtnUnableImage"];
    if (loginBtnNormalImage && loginBtnPressedImage && loginBtnUnableImage) {
        NSArray *images = @[[UIImage imageNamed:loginBtnNormalImage], [UIImage imageNamed:loginBtnPressedImage], [UIImage imageNamed:loginBtnUnableImage]];
        uiConfig.logBtnImgs = images;
    }

    /************** check box ***************/

    NSNumber *privacyOffsetY = [self getNumberValue:config key:@"privacyOffsetY"];
    NSNumber *privacyOffsetX = [self getValue:config key:@"privacyOffsetX"];

    CGFloat privacyCheckboxSize = [[self getNumberValue:config key:@"privacyCheckboxSize"] floatValue];
    if (privacyCheckboxSize == 0) {
        privacyCheckboxSize = 20.0;
    }
    BOOL privacyCheckboxInCenter = [[self getValue:config key:@"privacyCheckboxInCenter"] boolValue];

    BOOL privacyCheckboxHidden = [[self getValue:config key:@"privacyCheckboxHidden"] boolValue];
    uiConfig.checkViewHidden = privacyCheckboxHidden;
    CGFloat privacyLeftSpace = 0;

    if (privacyOffsetX == nil) {
        uiConfig.privacyTextAlignment = NSTextAlignmentCenter;
        privacyOffsetX = @(15);
    }
    privacyLeftSpace = privacyCheckboxHidden ? [privacyOffsetX floatValue] : ([privacyOffsetX floatValue] + privacyCheckboxSize + 5 + 5);//算上CheckBox的左右间隙;
    CGFloat privacyRightSpace = [privacyOffsetX floatValue];


    //checkbox
    JVLayoutConstraint *box_cons_x = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemPrivacy attribute:NSLayoutAttributeLeft multiplier:1 constant:-[privacyOffsetX floatValue] / 2];
    JVLayoutConstraint *box_cons_y = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemPrivacy attribute:NSLayoutAttributeTop multiplier:1 constant:3];
    if (privacyCheckboxInCenter) {
        box_cons_y = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemPrivacy attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    }
    JVLayoutConstraint *box_cons_w = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeWidth multiplier:1 constant:privacyCheckboxSize];
    JVLayoutConstraint *box_cons_h = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeHeight multiplier:1 constant:privacyCheckboxSize];

    uiConfig.checkViewConstraints = @[box_cons_x, box_cons_y, box_cons_w, box_cons_h];
    uiConfig.checkViewHorizontalConstraints = uiConfig.checkViewConstraints;

    NSNumber *privacyState = [self getValue:config key:@"privacyState"];
    uiConfig.privacyState = [privacyState boolValue];

    NSString *uncheckedImgPath = config[@"uncheckedImgPath"];
    if (uncheckedImgPath) {
        uiConfig.uncheckedImg = [UIImage imageNamed:uncheckedImgPath];
    }
    NSString *checkedImgPath = config[@"checkedImgPath"];
    if (checkedImgPath) {
        uiConfig.checkedImg = [UIImage imageNamed:checkedImgPath];
    }

    /************** privacy ***************/

    //自定义协议
    NSString *tempSting = @"";
    BOOL privacyWithBookTitleMark = [[self getValue:config key:@"privacyWithBookTitleMark"] boolValue];

    NSMutableArray *appPrivacyArr = [NSMutableArray array];
    if ([[config allKeys] containsObject:@"privacyText"] && [config[@"privacyText"] isKindOfClass:[NSArray class]]) {
        if ([config[@"privacyText"] count] >= 1) {
            [appPrivacyArr addObject:[config[@"privacyText"] objectAtIndex:0]];
            tempSting = [tempSting stringByAppendingString:[config[@"privacyText"] objectAtIndex:0]];
        }

    }

    if ([[config allKeys] containsObject:@"privacy"] && [config[@"privacy"] isKindOfClass:[NSString class]]) {
        NSArray *privacyArr = config[@"privacy"];
        for (NSUInteger i = 0; i < privacyArr.count; i++) {
            NSMutableArray *item = [NSMutableArray array];
            NSDictionary *obj = privacyArr[i];

            //加入协议之间的分隔符
            if ([[obj allKeys] containsObject:@"separator"]) {
                [item addObject:obj[@"separator"]];
                tempSting = [tempSting stringByAppendingString:obj[@"separator"]];
            }
            //加入name
            if ([[obj allKeys] containsObject:@"name"]) {
                [item addObject:obj[@"name"]];
                tempSting = [tempSting stringByAppendingFormat:@"%@%@%@", (privacyWithBookTitleMark ? @"《" : @""), obj[@"name"], (privacyWithBookTitleMark ? @"》" : @"")];

            }
            //加入url
            if ([[obj allKeys] containsObject:@"url"]) {
                [item addObject:obj[@"url"]];
            }
            //加入协议详细页面的导航栏文字 可以是NSAttributedString类型 自定义  这里是直接拿name进行展示
            if ([[obj allKeys] containsObject:@"name"]) {
                UIColor *privacyNavTitleTextColor = UIColorFromRGB(-1);
                if ([self getValue:config key:@"privacyNavTitleTextColor"]) {
                    privacyNavTitleTextColor = UIColorFromRGB([[self getValue:config key:@"privacyNavTitleTextColor"] intValue]);
                }
                NSNumber *privacyNavTitleTextSize = [self getValue:config key:@"privacyNavTitleTextSize"];
                if (!privacyNavTitleTextSize) {
                    privacyNavTitleTextSize = @(16);
                }
                NSDictionary *privacyNavTextAttr = @{NSForegroundColorAttributeName: privacyNavTitleTextColor,
                        NSFontAttributeName: [UIFont systemFontOfSize:[privacyNavTitleTextSize floatValue]]};
                NSAttributedString *privacyAttr = [[NSAttributedString alloc] initWithString:obj[@"name"] attributes:privacyNavTextAttr];
                if (privacyAttr) {
                    [item addObject:privacyAttr];
                }
            }
            //添加一条协议appPrivacyArr中
            [appPrivacyArr addObject:item];
        }
    }
    //设置尾部
    if ([[config allKeys] containsObject:@"privacyText"] && [config[@"privacyText"] isKindOfClass:[NSArray class]]) {
        if ([config[@"privacyText"] count] >= 2) {
            [appPrivacyArr addObject:[config[@"privacyText"] objectAtIndex:1]];
            tempSting = [tempSting stringByAppendingString:[config[@"privacyText"] objectAtIndex:1]];
        }
    }

    //设置
    if (appPrivacyArr.count > 1) {
        uiConfig.appPrivacys = appPrivacyArr;
    }

    BOOL privacyHintToast = [[self getValue:config key:@"privacyHintToast"] boolValue];
    if (privacyHintToast) {
        uiConfig.customPrivacyAlertViewBlock = ^(UIViewController *vc) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请点击同意协议" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [vc presentViewController:alert animated:true completion:nil];

        };
    }

    BOOL isCenter = [[self getValue:config key:@"privacyTextCenterGravity"] boolValue];
    NSTextAlignment alignment = isCenter ? NSTextAlignmentCenter : NSTextAlignmentLeft;
    uiConfig.privacyTextAlignment = alignment;

    uiConfig.privacyShowBookSymbol = privacyWithBookTitleMark;

    NSArray *privacyComponents = [self getValue:config key:@"privacyText"];
    if (![[config allKeys] containsObject:@"privacy"] && privacyComponents.count) {
        uiConfig.privacyComponents = privacyComponents;
        tempSting = [tempSting stringByAppendingString:[privacyComponents componentsJoinedByString:@"、"]];
    }

    NSNumber *privacyTextSize = [self getValue:config key:@"privacyTextSize"];
    if (privacyTextSize) {
        uiConfig.privacyTextFontSize = [privacyTextSize floatValue];
    }

//    JVLayoutItem privacyLayoutItem = [self getLayoutItem:[self getValue:config key:@"privacyVerticalLayout"]];

    CGFloat widthScreen = [UIScreen mainScreen].bounds.size.width;
    NSDictionary *popViewConfig = [self getValue:config key:@"popViewConfig"];
    if (popViewConfig) {
        widthScreen = [[self getValue:popViewConfig key:@"width"] intValue];
    }
    tempSting = [tempSting stringByAppendingString:@"《中国移动统一认证服务条款》"];
    CGFloat labelWidth = widthScreen - (privacyLeftSpace + privacyRightSpace);
    CGSize labelSize = [tempSting boundingRectWithSize:CGSizeMake(labelWidth, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:[privacyTextSize floatValue]]}
                                               context:nil].size;

    JVLayoutConstraint *privacy_cons_x = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeLeft multiplier:1 constant:privacyLeftSpace];
    JVLayoutConstraint *privacy_cons_y = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeBottom multiplier:1 constant:-[privacyOffsetY floatValue]];
    JVLayoutConstraint *privacy_cons_w = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeWidth multiplier:1 constant:labelWidth];
    JVLayoutConstraint *privacy_cons_h = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeHeight multiplier:1 constant:labelSize.height];

    uiConfig.privacyConstraints = @[privacy_cons_x, privacy_cons_y, privacy_cons_w, privacy_cons_h];
    uiConfig.privacyHorizontalConstraints = uiConfig.privacyConstraints;
    //隐私条款垂直对齐方式
    if ([[config allKeys] containsObject:@"textVerAlignment"]) {
        uiConfig.textVerAlignment = [config[@"textVerAlignment"] intValue];
    } else {
        uiConfig.textVerAlignment = JVVerAlignmentMiddle;
    }

    NSNumber *clauseBaseColor = [self getValue:config key:@"clauseBaseColor"];
    UIColor *privacyBasicColor = [UIColor grayColor];
    if (clauseBaseColor) {
        privacyBasicColor = UIColorFromRGB([clauseBaseColor integerValue]);
    }
    NSNumber *clauseColor = [self getValue:config key:@"clauseColor"];
    UIColor *privacyColor = UIColorFromRGB(-16007674);
    if (clauseColor) {
        privacyColor = UIColorFromRGB([clauseColor integerValue]);
    }
    uiConfig.appPrivacyColor = @[privacyBasicColor, privacyColor];

    /************** 协议 web 页面 ***************/
    NSNumber *privacyNavColor = [self getValue:config key:@"privacyNavColor"];
    if (privacyNavColor) {
        uiConfig.agreementNavBackgroundColor = UIColorFromRGB([privacyNavColor intValue]);
    }

    NSString *privacyNavText = [self getValue:config key:@"privacyNavTitleTitle"];
    if (!privacyNavText) {
        privacyNavText = @"运营商服务条款";
    }

    UIColor *privacyNavTitleTextColor = UIColorFromRGB(-1);
    if ([self getValue:config key:@"privacyNavTitleTextColor"]) {
        privacyNavTitleTextColor = UIColorFromRGB([[self getValue:config key:@"privacyNavTitleTextColor"] intValue]);
    }
    NSNumber *privacyNavTitleTextSize = [self getValue:config key:@"privacyNavTitleTextSize"];
    if (!privacyNavTitleTextSize) {
        privacyNavTitleTextSize = @(16);
    }
    NSDictionary *privacyNavTextAttr = @{NSForegroundColorAttributeName: privacyNavTitleTextColor,
            NSFontAttributeName: [UIFont systemFontOfSize:[privacyNavTitleTextSize floatValue]]};
    NSAttributedString *privacyAttr = [[NSAttributedString alloc] initWithString:privacyNavText attributes:privacyNavTextAttr];
    uiConfig.agreementNavText = privacyAttr;
    uiConfig.agreementNavTextColor = privacyNavTitleTextColor;

    NSString *privacyNavReturnBtnImage = [self getValue:config key:@"privacyNavReturnBtnImage"];
    if (privacyNavReturnBtnImage) {
        uiConfig.agreementNavReturnImage = [UIImage imageNamed:privacyNavReturnBtnImage];
    }

    // 自定义协议 1
    NSString *privacyNavTitleTitle1 = [self getValue:config key:@"privacyNavTitleTitle1"];
    if (!privacyNavTitleTitle1) {
        privacyNavTitleTitle1 = @"服务条款";
    }
    NSDictionary *privacyNavTextAttr1 = @{NSForegroundColorAttributeName: privacyNavTitleTextColor,
            NSFontAttributeName: [UIFont systemFontOfSize:[privacyNavTitleTextSize floatValue]]};
    NSAttributedString *privacyAttr1 = [[NSAttributedString alloc] initWithString:privacyNavTitleTitle1 attributes:privacyNavTextAttr1];
    uiConfig.firstPrivacyAgreementNavText = privacyAttr1;

    // 自定义协议 2
    NSString *privacyNavTitleTitle2 = [self getValue:config key:@"privacyNavTitleTitle2"];
    if (!privacyNavTitleTitle2) {
        privacyNavTitleTitle2 = @"服务条款";
    }
    NSDictionary *privacyNavTextAttr2 = @{NSForegroundColorAttributeName: privacyNavTitleTextColor,
            NSFontAttributeName: [UIFont systemFontOfSize:[privacyNavTitleTextSize floatValue]]};
    NSAttributedString *privacyAttr2 = [[NSAttributedString alloc] initWithString:privacyNavTitleTitle2 attributes:privacyNavTextAttr2];
    uiConfig.secondPrivacyAgreementNavText = privacyAttr2;

    /************** loading 框 ***************/
    JVLayoutConstraint *loadingConstraintX = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    JVLayoutConstraint *loadingConstraintY = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    JVLayoutConstraint *loadingConstraintW = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeWidth multiplier:1 constant:30];
    JVLayoutConstraint *loadingConstraintH = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeHeight multiplier:1 constant:30];

    uiConfig.loadingConstraints = @[loadingConstraintX, loadingConstraintY, loadingConstraintW, loadingConstraintH];
    uiConfig.loadingHorizontalConstraints = uiConfig.loadingConstraints;

    /************** 窗口模式样式设置 ***************/
    if (popViewConfig) {
        NSNumber *isPopViewTheme = [self getValue:popViewConfig key:@""];
        NSNumber *width = [self getValue:popViewConfig key:@"width"];
        NSNumber *height = [self getValue:popViewConfig key:@"height"];
        NSNumber *offsetCenterX = [self getValue:popViewConfig key:@"offsetCenterX"];
        NSNumber *offsetCenterY = [self getValue:popViewConfig key:@"offsetCenterY"];

        NSNumber *popViewCornerRadius = [self getValue:popViewConfig key:@"popViewCornerRadius"];
        NSNumber *backgroundAlpha = [self getValue:popViewConfig key:@"backgroundAlpha"];
        if ([isPopViewTheme boolValue]) {
            return;
        }

        uiConfig.showWindow = YES;
        uiConfig.navCustom = YES;
        uiConfig.windowCornerRadius = [popViewCornerRadius floatValue];
        uiConfig.windowBackgroundAlpha = [backgroundAlpha floatValue];

        // 弹窗模式背景图
        if (authBackgroundImage) {
            uiConfig.windowBackgroundImage = [UIImage imageNamed:authBackgroundImage];
        }

        CGFloat windowW = [width floatValue];
        CGFloat windowH = [height floatValue];
        CGFloat windowX = [offsetCenterX floatValue];
        CGFloat windowY = [offsetCenterY floatValue];
        JVLayoutConstraint *windowConstraintX = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeCenterX multiplier:1 constant:windowX];
        JVLayoutConstraint *windowConstraintY = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeCenterY multiplier:1 constant:windowY];
        JVLayoutConstraint *windowConstraintW = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeWidth multiplier:1 constant:windowW];
        JVLayoutConstraint *windowConstraintH = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeHeight multiplier:1 constant:windowH];
        uiConfig.windowConstraints = @[windowConstraintX, windowConstraintY, windowConstraintW, windowConstraintH];
        uiConfig.windowHorizontalConstraints = uiConfig.windowConstraints;
    }
}

#pragma mark - 添加 label

- (UILabel *)addCustomTextWidget:(NSDictionary *)widgetDic {
    UILabel *label = [[UILabel alloc] init];
    NSInteger left = [[self getValue:widgetDic key:@"left"] integerValue];
    NSInteger top = [[self getValue:widgetDic key:@"top"] integerValue];
    NSInteger width = [[self getValue:widgetDic key:@"width"] integerValue];
    CGFloat height = [[self getValue:widgetDic key:@"height"] integerValue];
    NSString *title = [self getValue:widgetDic key:@"title"];
    if (title) {
        label.text = title;
    }
    NSNumber *titleColor = [self getValue:widgetDic key:@"titleColor"];
    if (titleColor) {
        label.textColor = UIColorFromRGB([titleColor integerValue]);
    }
    NSNumber *backgroundColor = [self getValue:widgetDic key:@"backgroundColor"];
    if (backgroundColor) {
        label.backgroundColor = UIColorFromRGB([backgroundColor integerValue]);
    }
    NSString *textAlignment = [self getValue:widgetDic key:@"textAlignment"];
    if (textAlignment) {
        label.textAlignment = [self getTextAlignment:textAlignment];
    }

    NSNumber *font = [self getValue:widgetDic key:@"titleFont"];
    if (font) {
        label.font = [UIFont systemFontOfSize:[font floatValue]];
    }

    NSNumber *lines = [self getValue:widgetDic key:@"lines"];
    if (lines) {
        label.numberOfLines = [lines integerValue];
    }
    NSNumber *isSingleLine = [self getValue:widgetDic key:@"isSingleLine"];
    if (![isSingleLine boolValue]) {
        label.numberOfLines = 0;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:20],};
        CGSize textSize = [label.text boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
        height = textSize.height;
    }

    NSNumber *isShowUnderline = [self getValue:widgetDic key:@"isShowUnderline"];
    if ([isShowUnderline boolValue]) {
        NSDictionary *attributedDic = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:title attributes:attributedDic];
        label.attributedText = attributedStr;
    }

    NSString *widgetId = [self getValue:widgetDic key:@"widgetId"];

    label.frame = CGRectMake(left, top, width, height);

    NSNumber *isClickEnable = [self getValue:widgetDic key:@"isClickEnable"];
    if ([isClickEnable boolValue]) {
        NSString *tag = @(left + top + width + height).stringValue;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTextWidgetAction:)];
        [singleTapGestureRecognizer setNumberOfTapsRequired:1];
        [label addGestureRecognizer:singleTapGestureRecognizer];
        singleTapGestureRecognizer.view.tag = [tag integerValue];
        self.customWidgetIdDic[tag] = widgetId;
    }

    return label;
}

- (void)clickTextWidgetAction:(UITapGestureRecognizer *)gestureRecognizer {
    NSString *tag = [NSString stringWithFormat:@"%@", @(gestureRecognizer.view.tag)];
    if (tag) {
        NSString *widgetId = self.customWidgetIdDic[tag];
        [_channel invokeMethod:@"onReceiveClickWidgetEvent" arguments:@{@"widgetId": widgetId}];
    }
}


#pragma mark - 添加 button

- (UIButton *)addCustomButtonWidget:(NSDictionary *)widgetDic {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    NSInteger left = [[self getValue:widgetDic key:@"left"] integerValue];
    NSInteger top = [[self getValue:widgetDic key:@"top"] integerValue];
    NSInteger width = [[self getValue:widgetDic key:@"width"] integerValue];
    NSInteger height = [[self getValue:widgetDic key:@"height"] integerValue];

    NSString *title = [self getValue:widgetDic key:@"title"];
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateHighlighted];
    }
    NSNumber *titleColor = [self getValue:widgetDic key:@"titleColor"];
    if (titleColor) {
        [button setTitleColor:UIColorFromRGB([titleColor integerValue]) forState:UIControlStateNormal];
    }
    NSNumber *backgroundColor = [self getValue:widgetDic key:@"backgroundColor"];
    if (backgroundColor) {
        [button setBackgroundColor:UIColorFromRGB([backgroundColor integerValue])];
    }
    NSString *textAlignment = [self getValue:widgetDic key:@"textAlignment"];
    if (textAlignment) {
        button.contentHorizontalAlignment = [self getButtonTitleAlignment:textAlignment];
    }

    NSNumber *font = [self getValue:widgetDic key:@"titleFont"];
    if (font) {
        button.titleLabel.font = [UIFont systemFontOfSize:[font floatValue]];
    }


    NSNumber *isShowUnderline = [self getValue:widgetDic key:@"isShowUnderline"];
    if ([isShowUnderline boolValue]) {
        NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc] initWithString:title attributes:attribtDic];
        button.titleLabel.attributedText = attribtStr;
    }

    button.frame = CGRectMake(left, top, width, height);

    NSNumber *isClickEnable = [self getValue:widgetDic key:@"isClickEnable"];
    button.userInteractionEnabled = [isClickEnable boolValue];
    [button addTarget:self action:@selector(clickCustomWidgetAction:) forControlEvents:UIControlEventTouchUpInside];

    NSString *widgetId = [self getValue:widgetDic key:@"widgetId"];

    NSString *tag = @(left + top + width + height).stringValue;
    button.tag = [tag integerValue];


    self.customWidgetIdDic[tag] = widgetId;


    NSString *btnNormalImageName = [self getValue:widgetDic key:@"btnNormalImageName"];
    NSString *btnPressedImageName = [self getValue:widgetDic key:@"btnPressedImageName"];
    if (!btnPressedImageName) {
        btnPressedImageName = btnNormalImageName;
    }
    if (btnNormalImageName) {
        [button setBackgroundImage:[UIImage imageNamed:btnNormalImageName] forState:UIControlStateNormal];
    }
    if (btnPressedImageName) {
        [button setBackgroundImage:[UIImage imageNamed:btnPressedImageName] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:btnPressedImageName] forState:UIControlStateSelected];
    }

    return button;
}


- (UIModalTransitionStyle)getTransitionStyle:(NSString *)itemStr {
    if ([itemStr isEqualToString:@"flipHorizontal"]) {
        return UIModalTransitionStyleFlipHorizontal;
    } else if ([itemStr isEqualToString:@"crossDissolve"]) {
        return UIModalTransitionStyleCrossDissolve;
    } else if ([itemStr isEqualToString:@"partialCurl"]) {
        return UIModalTransitionStylePartialCurl;
    }
    return UIModalTransitionStyleCoverVertical;
}

- (UIStatusBarStyle)getStatusBarStyle:(NSString *)itemStr {
    if ([itemStr isEqualToString:@"defaultStyle"]) {
        return UIStatusBarStyleDefault;
    } else if ([itemStr isEqualToString:@"lightContent"]) {
        return UIStatusBarStyleLightContent;
    } else if ([itemStr isEqualToString:@"darkContent"]) {
        if (@available(iOS 13.0, *)) {
            return UIStatusBarStyleDarkContent;
        }
    }
    return UIStatusBarStyleDefault;
}


- (JVLayoutItem)getLayoutItem:(NSString *)itemString {
    JVLayoutItem item = JVLayoutItemNone;
    if (itemString) {
        if ([itemString isEqualToString:@"none"]) {
            item = JVLayoutItemNone;
        } else if ([itemString isEqualToString:@"logo"]) {
            item = JVLayoutItemLogo;
        } else if ([itemString isEqualToString:@"number"]) {
            item = JVLayoutItemNumber;
        } else if ([itemString isEqualToString:@"slogan"]) {
            item = JVLayoutItemSlogan;
        } else if ([itemString isEqualToString:@"login"]) {
            item = JVLayoutItemLogin;
        } else if ([itemString isEqualToString:@"check"]) {
            item = JVLayoutItemCheck;
        } else if ([itemString isEqualToString:@"privacy"]) {
            item = JVLayoutItemPrivacy;
        } else if ([itemString isEqualToString:@"superView"]) {
            item = JVLayoutItemSuper;
        } else {
            item = JVLayoutItemNone;
        }
    }
    return item;
}

- (NSTextAlignment)getTextAlignment:(NSString *)alignment {
    NSTextAlignment model = NSTextAlignmentLeft;
    if (alignment) {
        if ([alignment isEqualToString:@"left"]) {
            model = NSTextAlignmentLeft;
        } else if ([alignment isEqualToString:@"right"]) {
            model = NSTextAlignmentRight;
        } else if ([alignment isEqualToString:@"center"]) {
            model = NSTextAlignmentCenter;
        } else {
            model = NSTextAlignmentLeft;
        }
    }
    return model;
}

- (UIControlContentHorizontalAlignment)getButtonTitleAlignment:(NSString *)alignment {
    UIControlContentHorizontalAlignment model = UIControlContentHorizontalAlignmentCenter;
    if (alignment) {
        if ([alignment isEqualToString:@"left"]) {
            model = UIControlContentHorizontalAlignmentLeft;
        } else if ([alignment isEqualToString:@"right"]) {
            model = UIControlContentHorizontalAlignmentRight;
        } else if ([alignment isEqualToString:@"center"]) {
            model = UIControlContentHorizontalAlignmentCenter;
        } else {
            model = UIControlContentHorizontalAlignmentCenter;
        }
    }
    return model;
}

- (NSMutableDictionary *)customWidgetIdDic {
    if (!_customWidgetIdDic) {
        _customWidgetIdDic = [NSMutableDictionary dictionary];
    }
    return _customWidgetIdDic;
}

- (void)clickCustomWidgetAction:(UIButton *)button {
    NSString *tag = [NSString stringWithFormat:@"%@", @(button.tag)];
    if (tag) {
        NSString *widgetId = self.customWidgetIdDic[tag];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.channel invokeMethod:@"onReceiveClickWidgetEvent" arguments:widgetId];
        });

    }
}

#pragma mark - 其他

- (id)getValue:(NSDictionary *)arguments key:(NSString *)key {
    if (arguments && ![arguments[key] isKindOfClass:[NSNull class]]) {
        return arguments[key] ?: nil;
    } else {
        return nil;
    }
}

- (id)getNumberValue:(NSDictionary *)arguments key:(NSString *)key {
    if (arguments && ![arguments[key] isKindOfClass:[NSNull class]]) {
        return arguments[key] ?: @(0);
    } else {
        return @(0);
    }
}

@end
