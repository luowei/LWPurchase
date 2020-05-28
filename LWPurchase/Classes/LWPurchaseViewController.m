//
// Created by luowei on 2019/1/30.
// Copyright (c) 2019 luowei. All rights reserved.
//

#import "LWPurchaseViewController.h"
#import <Reachability/Reachability.h>
#import "LWPurchaseHelper.h"
#import <LWSDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import <FCAlertView/FCAlertView.h>


@interface LWPurchaseViewController ()<UITableViewDataSource,UITableViewDelegate,SKStoreProductViewControllerDelegate>

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSMutableArray<NSDictionary *> *dataList;

@property(nonatomic) BOOL isRestoreRequest;
@property(nonatomic, strong) SKProduct *iapProduct;

@end

@implementation LWPurchaseViewController {

}

+ (UINavigationController *)navigationViewController {
    LWPurchaseViewController *vc = [LWPurchaseViewController new];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:vc];
    return navigation;
}

- (void)leftItemaction {
    if(self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedStringFromTableInBundle(@"In-App Purchase", @"Local", LWPurchaseBundle(self), nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Close", @"Local", LWPurchaseBundle(self), nil)
            style:UIBarButtonItemStylePlain target:self action:@selector(leftItemaction)];


    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];

    [self reloadDataList];

    //监听产品请求处理通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProductRequestNotification:)
                                                 name:IAPProductRequestNotification
                                               object:[StoreManager sharedInstance]];
    //监听内购处理通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePurchasesNotification:)
                                                 name:IAPPurchaseNotification
                                               object:[StoreObserver sharedInstance]];


    //手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 5;
    tapGesture.numberOfTouchesRequired = 3;
    [tapGesture addTarget:self action:@selector(tapGestureAction:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture {
    if([[LWPurchaseHelper getValueByKey:Key_isPurchasedSuccessedUser] boolValue]){
        [LWPurchaseHelper setValue:nil key:Key_isPurchasedSuccessedUser];
    }else{
        [LWPurchaseHelper setValue:@(YES) key:Key_isPurchasedSuccessedUser];
    }
    [self updateBuyUI];
}

- (NSMutableArray<NSDictionary *> *)dataList {
    if (!_dataList) {
        NSString *purchase = NSLocalizedStringFromTableInBundle(@"Purchase", @"Local", LWPurchaseBundle(self), nil);
        NSString *restore = NSLocalizedStringFromTableInBundle(@"Restore", @"Local", LWPurchaseBundle(self), nil);
        _dataList = @[
                @{@"APP内购买": @[
                        @{@"icon": @"purchase", @"title": purchase, @"actionName": @"buyAction"},
                        @{@"icon": @"restore", @"title": restore, @"actionName": @"restoreAction"},
                ]},
//                @{@"好评鼓励一下开发者": @[
//                        @{@"icon": @"review", @"title": NSLocalizedString(@"Review", nil),@"actionName":@"reviewAction"},
//                ]},
//                @{@"应用推荐":@[
//                        @{@"icon": @"", @"title": @"我的浏览器",@"appId":@"1019594424"},
//                        @{@"icon": @"", @"title": @"斗图王",@"appId":@"1335365550"},
//                        @{@"icon": @"", @"title": @"美图王",@"appId":@"1281496162"},
//                        @{@"icon": @"", @"title": @"Mark记事本",@"appId":@"1274459069"},
//                        @{@"icon": @"", @"title": @"照片DIY",@"appId":@"1198477850"},
//                        ]}
        ].mutableCopy;
    }

    //只有需要购买，并且还未购买
    if ([LWPurchaseHelper isNeedPurchase] && ![LWPurchaseHelper isPurchased] && [LWPurchaseHelper isAfterDate:kAfterDate]) {
        NSString *secTitle = ((NSDictionary *) _dataList.firstObject).allKeys.firstObject;

        //没有配置评论，就添加一个评论选项
        if ([secTitle isKindOfClass:[NSString class]] && ![secTitle containsString:@"评"]
                && ![secTitle.lowercaseString containsString:@"review"]) {

            NSString *review = NSLocalizedStringFromTableInBundle(@"Review", @"Local", LWPurchaseBundle(self), nil);
            [_dataList insertObject:@{
                    @"好评鼓励": @[
                            @{@"icon": @"review", @"title": review, @"actionName": @"reviewAction"},
                    ]
            } atIndex:0];
        }
    }

    return _dataList;
}



#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionDict = self.dataList[(NSUInteger) section];
    NSArray *list = sectionDict.allValues.firstObject;
    return list.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }

    NSDictionary *sectionDict = self.dataList[(NSUInteger) indexPath.section];
    NSArray *list = sectionDict.allValues.firstObject;
    NSDictionary *item = list[indexPath.row];

    NSString *iconValue = item[@"icon"];
    if([iconValue hasPrefix:@"http"]){
        UIImage *placeholderImage = [UIImage imageNamed:@"imgIcon" inBundle:LWPurchaseBundle(self) compatibleWithTraitCollection:nil];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:iconValue] placeholderImage:placeholderImage];
        cell.imageView.layer.cornerRadius = 4;
        cell.imageView.clipsToBounds = YES;
    }else{
        UIImage *iconImage = [UIImage imageNamed:iconValue inBundle:LWPurchaseBundle(self) compatibleWithTraitCollection:nil];
        cell.imageView.image = iconImage;
    }

    if([item[@"actionName"] isEqualToString:@"buyAction"] && [LWPurchaseHelper isPurchased]){
        cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Thanks for Your Surpport", @"Local", LWPurchaseBundle(self), nil);
    }else{
        cell.textLabel.text = item[@"title"];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 28;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionDict = self.dataList[(NSUInteger) section];
    NSString *title = sectionDict.allKeys.firstObject;
    if([title hasPrefix:@"--"]){
        return nil;
    }else{
        return title;
    };
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *sectionDict = self.dataList[(NSUInteger) indexPath.section];
    NSArray *list = sectionDict.allValues.firstObject;
    NSDictionary *item = list[indexPath.row];

    NSString *actionName = item[@"actionName"];
    if(actionName.length > 0){
        if([actionName isEqualToString:@"buyAction"] && [LWPurchaseHelper isPurchased]){
            return;
        }else{
            [self performSelector:NSSelectorFromString(actionName)];
        }

    }else {
        NSString *appId = item[@"appId"];
        if(!appId || appId.length == 0){
            [MyPurchaseUIHelper showHUDWithMessage:NSLocalizedStringFromTableInBundle(@"Error Occursed", @"Local", LWPurchaseBundle(self), nil)];
            return;
        }
        SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
        storeProductViewContorller.delegate = self;
        //加载App Store视图展示
        [MyPurchaseUIHelper showHUDLoading];
        [storeProductViewContorller
                loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: appId}
                          completionBlock:^(BOOL result, NSError *error) {
                              [MyPurchaseUIHelper hideHUDLoading];
                              if (!error) {    ////模态弹出appstore
                                  [self presentViewController:storeProductViewContorller animated:YES completion:nil];
                              }
                          }];
    }

}


- (NSMutableArray *)reloadDataList {
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf requestDataFromNetwork];    //从网络请求数据
        });

    }else {
        [self requestDataFromLocal];    //从本地请求数据
    }

    return _dataList;
}

//从本地请求数据
- (void)requestDataFromLocal {
    if (!_dataList) {
        NSString *filePath = [LWPurchaseBundle(self) pathForResource:@"IAPConfig" ofType:@"json"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *dict = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:fileData options:0 error:nil];
        _dataList = [dict[@"data"] mutableCopy];
        NSMutableDictionary *purchaseConfig = [dict[@"purchaseConfig"] mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [LWPurchaseHelper refreshPurchaseConfig:purchaseConfig];
        });
    }
}


- (void)requestDataFromNetwork {
    NSString *urlStr = [NSString stringWithFormat:IAPConfig_URLString];
    NSURL *url = [NSURL URLWithString:urlStr];
    __weak typeof(self) weakSelf = self;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url]
               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                   __strong typeof(weakSelf) strongSelf = weakSelf;
                   if (!error) {
                       NSDictionary *dict = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                       if(dict){
                           strongSelf.dataList = [dict[@"data"] mutableCopy];
                           NSMutableDictionary *purchaseConfig = [dict[@"purchaseConfig"] mutableCopy];
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [strongSelf.tableView reloadData];
                               [LWPurchaseHelper refreshPurchaseConfig:purchaseConfig];
                           });

                       }else{
                           [strongSelf requestDataFromLocal];
                       }

                   } else {
                       [strongSelf requestDataFromLocal];
                       NSLog(@"NSURLSession dataTaskWithURL faild:%@,%@", error.localizedFailureReason, error.localizedDescription);
                   }
    }];
    [task resume];
}



#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

//评论
- (void)reviewAction {
    if (@available(iOS 10.3,*)) {
        //一句话实现在App内直接评论了。然而需要注意的是：打开次数一年不能多于3次。（当然开发期间可以无限制弹出，方便测试）
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        [SKStoreReviewController requestReview];
    } else {
        NSString *urlString2Open = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", @"1227288468"];//1227288468为万能输入法的APPID
        NSURL *url = [NSURL URLWithString:urlString2Open];
        if (@available(iOS 10.0,*)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }

}

#pragma mark - 内购处理

//开始购买
- (void)buyAction {
    self.isRestoreRequest = NO;
    NSNumber *isPurchasedValue = [LWPurchaseHelper getValueByKey:Key_isPurchasedSuccessedUser];
    if(![isPurchasedValue boolValue]){ //还未赋初值或还未购买
        [self fetchProductInformation]; //获取内购产品
    }else {
        NSString *msg = NSLocalizedStringFromTableInBundle(@"Have been purchased", @"Local", LWPurchaseBundle(self), nil);
        [MyPurchaseUIHelper showHUDWithDetailMessage:msg];
    }
}

//恢复购买
- (void)restoreAction {
    self.isRestoreRequest = YES;
    NSNumber *isPurchasedValue = [LWPurchaseHelper getValueByKey:Key_isPurchasedSuccessedUser];
    if(![isPurchasedValue boolValue]){ //还未赋初值或还未购买
        [self fetchProductInformation]; //获取内购产品
    }else {
        NSString *msg = NSLocalizedStringFromTableInBundle(@"Have been purchased", @"Local", LWPurchaseBundle(self), nil);
        [MyPurchaseUIHelper showHUDWithDetailMessage:msg];
    }
}


//从AppStore获取内购产品信息
- (void)fetchProductInformation {
    if ([SKPaymentQueue canMakePayments]) {
        NSArray<NSString *> *productIds = @[IAPProductId];
        [[StoreManager sharedInstance] fetchProductInformationForIds:productIds];
    } else {
        NSString *msg = NSLocalizedStringFromTableInBundle(@"Purchases Disabled on this device.", @"Local", LWPurchaseBundle(self), nil);
        [MyPurchaseUIHelper showHUDWithDetailMessage:msg];
    }
}

//处理内购产品请求结果通知
- (void)handleProductRequestNotification:(NSNotification *)notification {
    StoreManager *storeManager = (StoreManager *) notification.object;
    IAPProductRequestStatus result = (IAPProductRequestStatus) storeManager.status;

    if (result == IAPProductRequestResponse) {
        NSArray *models = storeManager.responseModels;
        for (MyModel *model in models) {

            NSArray<SKProduct *> *products = model.elements;
            if ([model.name isEqualToString:@"AVAILABLE PRODUCTS"]) {

                SKProduct *iapProduct = products.firstObject;
                if([IAPProductId isEqualToString:iapProduct.productIdentifier]){
                    self.iapProduct = iapProduct;
                    if(self.isRestoreRequest){
                        //首次安装走恢复购买
                        [[StoreObserver sharedInstance] restoreWithProduct:iapProduct];   //恢复购买
                    }else{
                        //显示购买产品弹窗
                        [self showProductAlert:iapProduct];
                    }
                    return;
                }
            }
        }

    }
}

//显示购买产品弹窗
- (void)showProductAlert:(SKProduct *)iapProduct {
    NSString *title = iapProduct.localizedTitle;
    NSString *price = [NSString stringWithFormat:@"%@%@", [iapProduct.priceLocale objectForKey:NSLocaleCurrencySymbol], iapProduct.price];
    NSString *dtext = NSLocalizedStringFromTableInBundle(@"Support Developer", @"Local", LWPurchaseBundle(self), nil);
    NSString *descText = [NSString stringWithFormat:@"%@\n%@%@",iapProduct.localizedDescription, dtext,price];
    NSLog(@"====availabel===title:%@, price:%@",title,price);


    //弹窗
    FCAlertView *alert = [FCAlertView new];
    alert.avoidCustomImageTint = YES;
    [alert makeAlertTypeSuccess];
    //alert.blurBackground = YES;
    alert.bounceAnimations = YES;

    __weak typeof(alert) weakAlert = alert;
    [alert doneActionBlock:^{
        __strong typeof(weakAlert) strongAlert = weakAlert;

        [[StoreObserver sharedInstance] buy:iapProduct];    //执行购买
        [strongAlert dismissAlertView];
    }];
    [alert addButton:NSLocalizedStringFromTableInBundle(@"Cancel", @"Local", LWPurchaseBundle(self), nil)
     withActionBlock:^{
        __strong typeof(weakAlert) strongAlert = weakAlert;
        [strongAlert dismissAlertView];
    }];

    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [alert showAlertInWindow:keyWindow withTitle:title withSubtitle:descText
             withCustomImage:nil withDoneButtonTitle:NSLocalizedStringFromTableInBundle(@"Ok", @"Local", LWPurchaseBundle(self), nil)
                  andButtons:nil];

    //消息提示
    NSNumber *value = [LWPurchaseHelper getValueByKey:Key_isPurchasedSuccessedUser];
    if(!value){  //新安装
        [MyPurchaseUIHelper showHUDWithDetailMessage:NSLocalizedStringFromTableInBundle(@"RePurchased Free", @"Local", LWPurchaseBundle(self), nil)];
    }

}


//处理购买结果通知
- (void)handlePurchasesNotification:(NSNotification *)notification {
    StoreObserver *storeObserver = (StoreObserver *) notification.object;
    IAPPurchaseNotificationStatus status = (IAPPurchaseNotificationStatus) storeObserver.status;

    switch (status) {
        case IAPPurchaseFailed:
            [LWPurchaseHelper setValue:@NO key:Key_isPurchasedSuccessedUser];
            [MyPurchaseUIHelper showHUDWithDetailMessage:storeObserver.message];
            [self updateBuyUI]; //更新购买UI
            break;
        case IAPPurchaseSucceeded:
        case IAPRestoredSucceeded: {
            [LWPurchaseHelper setValue:@YES key:Key_isPurchasedSuccessedUser];
            [MyPurchaseUIHelper showHUDWithDetailMessage:storeObserver.message];
            [self updateBuyUI]; //更新购买UI
            break;
        }
        case IAPRestoredFailed:
            [LWPurchaseHelper setValue:@NO key:Key_isPurchasedSuccessedUser];
            [MyPurchaseUIHelper showHUDWithDetailMessage:storeObserver.message];
            [self updateBuyUI]; //更新购买UI
            break;
        case IAPDownloadStarted: {
            break;
        }
        case IAPDownloadInProgress: {
            //[NSString stringWithFormat:@" Downloading %@   %.2f%%", displayedTitle, storeObserver.downloadProgress];
            break;
        }
        case IAPDownloadSucceeded: {
            [LWPurchaseHelper setValue:@YES key:Key_isPurchasedSuccessedUser];
            //[MyHelper showHUDWithDetailMessage:storeObserver.message];
            [self updateBuyUI]; //更新购买UI
            break;
        }
        default:
            break;
    }
}

/*
 * 更新购买UI
 */
- (void)updateBuyUI {
    [self.tableView reloadData];
//    if([LWPurchaseHelper isPurchased]){
//        //todo:
//    } else {
//
//    }
}


@end




@implementation MyPurchaseUIHelper

//显示提示窗
+ (void)showToastAlert:(NSString *)message {
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil, nil];
    [toast show];
    int duration = 1; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
}

//获得屏幕大小
+ (CGSize)fixedScreenSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    } else {
        return screenSize;
    }
}



+(void)showHUDWithMessage:(NSString *)message{
    if(!message || message.length == 0){
        return;
    }
    LWHUD *hud = [LWHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.label.text = message;
    hud.mode = LWHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}
+(void)showHUDWithDetailMessage:(NSString *)message{
    if(!message || message.length == 0){
        return;
    }
    LWHUD *hud = [LWHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.detailsLabel.text = message;
    hud.mode = LWHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}

+(LWHUD *)showHUDWithMessage:(NSString *)message mode:(LWHUDMode)mode {
    LWHUD *hud = [LWHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.label.text = message;
    hud.mode = mode;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

+ (void)showHUDLoading {
    LWHUD *hud = [LWHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = LWHUDModeIndeterminate;
    hud.removeFromSuperViewOnHide = YES;
    [hud showAnimated:YES];
}

+(void)hideHUDLoading {
    UIWindow *keywindow = [UIApplication sharedApplication].keyWindow;
    for(UIView *view in keywindow.subviews){
        if([view isKindOfClass:[LWHUD class]]){
            [(LWHUD *)view hideAnimated:NO];
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Check Status




#pragma mark - Cloud

//在Documents目录下创建一个名为InputBgImg的文件夹
+ (NSString *)createIfNotExistsDirectory:(NSString *)dirName {

    NSFileManager *fmanager = [NSFileManager defaultManager];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:dirName];
    BOOL isDir = NO;
    BOOL isDirExist = [fmanager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDirExist && isDir)){
        [fmanager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

//不备份某个目录
+ (void)iCloudBackupPath:(NSString *)path skip:(BOOL)value{
    NSURL *url = [NSURL fileURLWithPath:path];
    // 设置 do not back up属性
    if(![[NSFileManager defaultManager] fileExistsAtPath:url.path]){
        return;
    }

    NSError *error = nil;
    BOOL success = [url setResourceValue:@(value) forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }
    return;
}

//获得icloundDocumentURL
+(NSURL *)icloudDocumentURL {
    NSURL *icloudDocumentURL = nil;
    NSURL *icloudURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:@"iCloud.com.wodedata.iCloud-MyInputMethod"];
    if(icloudURL){
        icloudDocumentURL = [icloudURL URLByAppendingPathComponent:@"Documents"];
    }

    return icloudDocumentURL;
}

//检查是否已购买
+ (BOOL)checkIsPurchase {
    if(![LWPurchaseHelper isPurchased]){
        NSString *msg = NSLocalizedStringFromTableInBundle(@"Purchase remove all limits", @"Local", LWPurchaseBundle(self), nil);
        [MyPurchaseUIHelper showHUDWithMessage:msg];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSURL *purchaseURL = [NSURL URLWithString:@"LWInputMethod://other.app_purchase"];
            if (@available(iOS 10.0,*)) {
                [[UIApplication sharedApplication] openURL:purchaseURL options:@{} completionHandler:nil];
            }else{
                [[UIApplication sharedApplication] openURL:purchaseURL];
            }
        });
        return NO;
    }

    return YES;
}

@end


