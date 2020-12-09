//
// Created by luowei on 2019/1/30.
// Copyright (c) 2019 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LWHUD/LWHUD.h>
#import "StoreManager.h"
#import "StoreObserver.h"

@class LWHUD;

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif

#define LWPurchaseBundle(obj)  ([NSBundle bundleWithPath:[[NSBundle bundleForClass:[obj class]] pathForResource:@"LWPurchase" ofType:@"bundle"]] ?: ([NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"LWPurchase" ofType:@"bundle"]] ?: [NSBundle mainBundle]))

//#define IAPProductId (@"com.wodedata.MyInputMethod_AllPowerfulKey")   //内购ProductId
#define IAPProductId (@"com.wodedata.WBInputMethod_NoAds")   //内购ProductId
//#define IAPProductId (@"com.wodedata.ChildrenEnglish_NoAds")   //内购ProductId
//#define IAPProductId (@"com.wodedata.LWCalendar_NoAds")   //内购ProductId
//#define IAPProductId (@"com.wodedata.GIFEmoji_NoAds")   //内购ProductId
//#define IAPProductId (@"com.wodedata.MyBrowserNoLimit")   //内购ProductId


//#define IAPConfig_URLString @"http://wodedata.com/MyResource/MyInputMethod/data_iapconfig.json"
#define IAPConfig_URLString @"http://wodedata.com/MyResource/WBInput/data_iapconfig.json"
//#define IAPConfig_URLString @"http://wodedata.com/MyResource/MyBrowser/data_iapconfig.json"

#define Key_isPurchasedSuccessedUser  @"Key_isPurchasedSuccessedUser"   //IAP购买成功
#define Key_RatingTriggerCount  @"Key_RatingTriggerCount"

#define Key_AppPrice  @"appPrice"
#define Key_needPurchase  @"needPurchase"
#define Key_tryRatingTriggerCount  @"tryRatingTriggerCount"
#define Key_ratedTriggerCount  @"ratedTriggerCount"
#define Key_currentTriggerCount  @"currentTriggerCount"

#define APP_Lookup @"http://itunes.apple.com/cn/lookup?id=1335365550"
#define APP_Reviews @"https://itunes.apple.com/cn/rss/customerreviews/id=1522850307/json"

#define kAfterDate @"2020-12-05"

//#define AppGroupIdentifer @"group.com.wodedata.LWInputMethod"
#define AppGroupIdentifer @"group.com.wodedata.WBInputMethod"
//#define AppGroupIdentifer @"group.com.wodedata.test"


@interface LWPurchaseViewController : UIViewController

@property (nonatomic) BOOL needPrePurchase;

+ (UINavigationController *)navigationViewController;

@end



@interface MyPurchaseUIHelper : NSObject

//显示提示窗
+ (void)showToastAlert:(NSString *)message;

//获得屏幕大小
+ (CGSize)fixedScreenSize;


+(void)showHUDWithMessage:(NSString *)message;
+(void)showHUDWithDetailMessage:(NSString *)message;

+ (void)showHUDLoading;
+(void)hideHUDLoading;

+(LWHUD *)showHUDWithMessage:(NSString *)message mode:(LWHUDMode)mode;


//在Documents目录下创建一个名为InputBgImg的文件夹
+ (NSString *)createIfNotExistsDirectory:(NSString *)dirName;

//不备份某个目录
+ (void)iCloudBackupPath:(NSString *)path skip:(BOOL)value;

//获得icloundDocumentURL
+(NSURL *)icloudDocumentURL;


+ (BOOL)checkIsPurchase;
@end
