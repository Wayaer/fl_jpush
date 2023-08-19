#import <Flutter/Flutter.h>

@interface FlJVerifyPlugin : NSObject <FlutterPlugin>
@property FlutterMethodChannel *channel;
/// 添加的自定义控件的 id
@property(nonatomic, strong) NSMutableDictionary *customWidgetIdDic;

@end
