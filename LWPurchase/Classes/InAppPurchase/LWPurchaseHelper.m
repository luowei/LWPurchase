//
// Created by Luo Wei on 2019/2/17.
// Copyright (c) 2019 wodedata. All rights reserved.
//

#import "LWPurchaseHelper.h"
#import "LWPurchaseViewController.h"

@implementation LWPurchaseHelper {

}

+ (instancetype)shareInstance {
    static LWPurchaseHelper *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];

    });
    return _instance;
}

//获得两个时间之间的日差
+ (NSInteger)daysBetweenDate:(NSString *)fromDateTime andDate:(NSString *)toDateTime {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *from = [dateFormatter dateFromString:fromDateTime];
    NSDate *to = [dateFormatter dateFromString:toDateTime];

    NSDate *fromDate;
    NSDate *toDate;
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:from];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:to];

    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    return [difference day];
}


//判断是否是指定日期之后,dateString 格式 ：yyyy-MM-dd
+ (BOOL)isAfterDate:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger days = [LWPurchaseHelper daysBetweenDate:dateString andDate:currentDate];
    return days >= 0;
}

//是否已经购买过了
+(BOOL)isPurchased {
//    return YES;
    NSNumber *isPurchasedValue = [LWPurchaseHelper getValueByKey:Key_isPurchasedSuccessedUser];
    BOOL isPurchased = isPurchasedValue && [isPurchasedValue boolValue];
    if(!isPurchased){
        isPurchased = ![LWPurchaseHelper isNeedPurchase];   //不须要购买，则表示已经购买
    }
    return isPurchased;
}

//是否需要内购
+ (BOOL)isNeedPurchase {
    BOOL hidePurchaseEntry = [[LWPurchaseHelper getValueByKey:Key_hidePurchaseEntry] boolValue];
    if(hidePurchaseEntry){ //如果隐藏了购买入口，则不需要购买
        return NO;
    }

    BOOL isNeedPurchase = [[LWPurchaseHelper getValueByKey:Key_needPurchase] boolValue];
    if (!isNeedPurchase) {
        double appPrice = [[LWPurchaseHelper getValueByKey:Key_AppPrice] doubleValue];
        isNeedPurchase = appPrice <= 3; //小于3块钱,自动开启内购
    }
    return isNeedPurchase;
}

//隐藏购买入口
+ (BOOL)hidePurchaseEntry {
    return [[LWPurchaseHelper getValueByKey:Key_hidePurchaseEntry] boolValue];
}

+ (void)reloadAppPriceWithCompleteBlock:(void (^)(double price))completeBlock {
    NSString *urlStr = [NSString stringWithFormat:APP_Lookup];
    NSURL *url = [NSURL URLWithString:urlStr];
    __weak typeof(self) weakSelf = self;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url]
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                __strong typeof(weakSelf) strongSelf = weakSelf;
                                                if (!error) {
                                                    NSDictionary *dict = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                    if (dict) {
                                                        id results = [dict valueForKeyPath:@"results"];
                                                        if([results isKindOfClass:[NSArray class]]){
                                                            results = ((NSArray *)results).firstObject;
                                                        }
                                                        NSDictionary *dic = [results isKindOfClass:[NSDictionary class]] ? ((NSDictionary *)results) : nil;
                                                        id price = [dic valueForKeyPath:@"price"];
                                                        double dbPrice = 0;
                                                        if([price isKindOfClass:[NSNumber class]] || [price isKindOfClass:[NSString class]]){
                                                            [LWPurchaseHelper setValue:price key:Key_AppPrice];
                                                            dbPrice = [price doubleValue];
                                                        }
                                                        if (completeBlock) {
                                                            completeBlock(dbPrice);
                                                        }
                                                    }

                                                }
                                            }];
    [task resume];
}

//显示评分
+ (void)showRating {
    //首次触发需要达的数目
    NSInteger tryTriggerCnt = [[LWPurchaseHelper getValueByKey:Key_tryRatingTriggerCount] integerValue];
    tryTriggerCnt = tryTriggerCnt > 0 ? tryTriggerCnt : 50;
    //后续每次需要达到ratedTriggerCnt的倍数才触发
    NSInteger ratedTriggerCnt = [[LWPurchaseHelper getValueByKey:Key_ratedTriggerCount] integerValue];
    ratedTriggerCnt = ratedTriggerCnt > 0 ? ratedTriggerCnt : 200;
    //当前计数器
    NSInteger currentTriggerCnt = [[LWPurchaseHelper getValueByKey:Key_currentTriggerCount] integerValue];

    BOOL shouldTrigger = currentTriggerCnt == tryTriggerCnt;
    if (!shouldTrigger) {
        shouldTrigger = (currentTriggerCnt - tryTriggerCnt) % ratedTriggerCnt == 0;
    }

    //未内购，并且触发了评论
    if (shouldTrigger && @available(iOS 10.3, *)) {
        [SKStoreReviewController requestReview];
    }

    currentTriggerCnt ++;
    [LWPurchaseHelper setValue:@(currentTriggerCnt) key:Key_currentTriggerCount];
}

//加载needPurchaseConfig
+ (void)reloadNeedPurchaseConfig {

    NSString *urlStr = [NSString stringWithFormat:IAPConfig_URLString];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url]
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                if (!error) {
                                                    NSDictionary *dict = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                    if (dict) {
                                                        NSMutableDictionary *purchaseConfig = [dict[@"purchaseConfig"] mutableCopy];
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [LWPurchaseHelper refreshPurchaseConfig:purchaseConfig];
                                                        });

                                                    } else {
                                                        [LWPurchaseHelper loadPurchaseConfigFromLocal];
                                                    }

                                                } else {
                                                    [LWPurchaseHelper loadPurchaseConfigFromLocal];
                                                    NSLog(@"NSURLSession dataTaskWithURL faild:%@,%@", error.localizedFailureReason, error.localizedDescription);
                                                }
                                            }];
    [task resume];

}

+ (void)loadPurchaseConfigFromLocal {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"IAPConfig" ofType:@"json"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    if(!fileData){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dict = @{
                Key_needPurchase:@(YES),
                Key_hidePurchaseEntry:@(NO),
                Key_tryRatingTriggerCount:@(20),
                Key_ratedTriggerCount:@(100)
            };
            [LWPurchaseHelper refreshPurchaseConfig:dict];
            return;
        });
        return;
    }
    NSDictionary *dict = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:fileData options:0 error:nil];
    NSMutableDictionary *purchaseConfig = [dict[@"purchaseConfig"] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [LWPurchaseHelper refreshPurchaseConfig:purchaseConfig];
    });
}


+(void)refreshPurchaseConfig:(NSDictionary *)configDict {
    [LWPurchaseHelper setValue:configDict[Key_needPurchase] key:Key_needPurchase];
    [LWPurchaseHelper setValue:configDict[Key_hidePurchaseEntry] key:Key_hidePurchaseEntry];
    [LWPurchaseHelper setValue:configDict[Key_tryRatingTriggerCount] key:Key_tryRatingTriggerCount];
    [LWPurchaseHelper setValue:configDict[Key_ratedTriggerCount] key:Key_ratedTriggerCount];
}



#pragma mark - UserDefautls

+(id)getValueByKey:(NSString *)key {
    id value = [LWPurchaseHelper getMyInputMethodAPPGroupValueByKey:key];
    if(!value){
        value = [LWPurchaseHelper getUserDefaultValueByKey:key];
        [LWPurchaseHelper setMyInputMethodAPPGroupValue:value withKey:key];
    }
    return value;
}

+(void)setValue:(id)value key:(NSString *)key {
    [LWPurchaseHelper setUserDefaultValue:value withKey:key];
    [LWPurchaseHelper setMyInputMethodAPPGroupValue:value withKey:key];
}


//从UserDefault中取值
+(id)getUserDefaultValueByKey:(NSString *)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:key];
}

//向UserDefault设置值
+(void)setUserDefaultValue:(id)value withKey:(NSString *)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

//从APP Group中取值
+(id)getMyInputMethodAPPGroupValueByKey:(NSString *)key {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:AppGroupIdentifer];
    return [userDefaults objectForKey:key];
}

//向APP Group中设置值
+(void)setMyInputMethodAPPGroupValue:(id)value withKey:(NSString *)key {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:AppGroupIdentifer];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

@end