//
// Created by luowei on 2019/1/30.
// Copyright (c) 2019 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LWHUD/LWHUD.h>
#import "StoreManager.h"
#import "StoreObserver.h"

@class LWHUD;

#define LWPurchaseBundle(obj)  ([NSBundle bundleWithPath:[[NSBundle bundleForClass:[obj class]] pathForResource:@"LWPurchase" ofType:@"bundle"]] ?: ([NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"LWPurchase" ofType:@"bundle"]] ?: [NSBundle mainBundle]))

#define IAPProductId (@"com.wodedata.MyInputMethod_AllPowerfulKey")   //内购ProductId

#define IAPConfig_URLString @"http://wodedata.com/MyResource/MyInputMethod/data_iapconfig.json"

#define Key_isPurchasedSuccessedUser  @"Key_isPurchasedSuccessedUser"   //IAP购买成功
#define Key_RatingTriggerCount  @"Key_RatingTriggerCount"

#define Key_AppPrice  @"appPrice"
#define Key_needPurchase  @"needPurchase"
#define Key_tryRatingTriggerCount  @"tryRatingTriggerCount"
#define Key_ratedTriggerCount  @"ratedTriggerCount"
#define Key_currentTriggerCount  @"currentTriggerCount"

#define APP_Lookup @"http://itunes.apple.com/cn/lookup?id=1227288468"
#define APP_Reviews @"https://itunes.apple.com/cn/rss/customerreviews/id=1227288468/json"

#define kAfterDate @"2020-07-01"

#define AppGroupIdentifer @"group.com.wodedata.LWInputMethod"


@interface LWPurchaseViewController : UIViewController

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
