//
// Created by Luo Wei on 2019/2/17.
// Copyright (c) 2019 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LWPurchaseHelper : NSObject

+ (instancetype)shareInstance;

+(void)refreshPurchaseConfig:(NSDictionary *)configDict;

//判断是否是指定日期之后,dateString 格式 ：yyyy-MM-dd
+ (BOOL)isAfterDate:(NSString *)dateString;
//获得两个时间之间的日差
+ (NSInteger)daysBetweenDate:(NSString *)fromDateTime andDate:(NSString *)toDateTime;

//是否已经购买过了
+(BOOL)isPurchased;

//是否需要内购
+ (BOOL)isNeedPurchase;

//隐藏购买入口
+ (BOOL)hidePurchaseEntry;

//重新加载APP的价格
+ (void)reloadAppPriceWithCompleteBlock:(void (^)(double price))completeBlock;

//加载needPurchaseConfig
+ (void)reloadNeedPurchaseConfig;

//显示评分
+ (void)showRating;


#pragma mark - UserDefaults

+(id)getValueByKey:(NSString *)key;
+(void)setValue:(id)value key:(NSString *)key;

//从UserDefault中取值
+(id)getUserDefaultValueByKey:(NSString *)key;

//向UserDefault设置值
+(void)setUserDefaultValue:(id)value withKey:(NSString *)key;

@end