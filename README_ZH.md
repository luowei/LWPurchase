# LWPurchase

[![CI Status](https://img.shields.io/travis/luowei/LWPurchase.svg?style=flat)](https://travis-ci.org/luowei/LWPurchase)
[![Version](https://img.shields.io/cocoapods/v/LWPurchase.svg?style=flat)](https://cocoapods.org/pods/LWPurchase)
[![License](https://img.shields.io/cocoapods/l/LWPurchase.svg?style=flat)](https://cocoapods.org/pods/LWPurchase)
[![Platform](https://img.shields.io/cocoapods/p/LWPurchase.svg?style=flat)](https://cocoapods.org/pods/LWPurchase)

## 简介

LWPurchase 是一个轻量级的 iOS 应用内购买（In-App Purchase）组件，专门用于非消耗型内购产品。只需一行代码即可快速集成完整的内购功能到您的应用中。

### 主要特性

- **极简集成**：一行代码即可打开内购页面
- **非消耗型内购**：专为永久解锁功能设计（如去广告、解锁专业版等）
- **完整功能**：支持购买、恢复购买、价格显示等完整内购流程
- **配置灵活**：支持远程 JSON 配置文件动态控制内购行为
- **App Group 支持**：可在 Extension 中同步内购信息
- **多语言支持**：内置中文简体、繁体、英文、日文等多语言
- **界面友好**：提供开箱即用的内购界面，支持自定义
- **评分引导**：内置智能评分提醒功能

## 系统要求

- iOS 8.0 或更高版本
- Xcode 11.0 或更高版本
- 支持 Objective-C 项目

## 安装方式

### CocoaPods

LWPurchase 可通过 [CocoaPods](https://cocoapods.org) 安装。只需在 Podfile 中添加以下内容：

```ruby
pod 'LWPurchase'
```

然后运行：

```bash
pod install
```

### Carthage

您也可以使用 Carthage 来安装 LWPurchase：

```ruby
github "luowei/LWPurchase"
```

## 快速开始

### 1. 基本用法

只需一行代码即可打开内购页面：

```objective-c
#import <LWPurchase/LWPurchaseViewController.h>

// 打开App内购页面
- (IBAction)btnAction:(UIButton *)sender {
    UINavigationController *navigation = [LWPurchaseViewController navigationViewController];
    [self presentViewController:navigation animated:YES completion:^{}];
}
```

### 2. 配置必需参数

集成后，您需要在 `LWPurchaseViewController.h` 中修改配置宏为您自己的信息：

```objective-c
// 步骤1: 修改为您自己的内购 Product ID
#define IAPProductId (@"com.yourcompany.YourApp_NoAds")

// 步骤2: 配置远程配置文件地址
// 将 Assets 目录下的 IAPConfig.json 修改后上传到您的服务器
#define IAPConfig_URLString @"http://yourserver.com/path/to/IAPConfig.json"

// 步骤3: 如果需要在 Extension 中同步内购信息，配置 App Group
#define AppGroupIdentifer @"group.com.yourcompany.yourapp"
```

### 3. 配置文件说明

`IAPConfig.json` 配置文件结构：

```json
{
  "data": [
    {
      "APP内购买": [
        {
          "icon": "purchase",
          "title": "购买",
          "actionName": "buyAction"
        },
        {
          "icon": "restore",
          "title": "恢复购买",
          "actionName": "restoreAction"
        }
      ]
    }
  ],
  "purchaseConfig": {
    "needPurchase": true,           // 是否需要内购
    "hidePurchaseEntry": false,     // 是否隐藏内购入口
    "needKeyboardPurchase": true,   // 键盘是否需要购买
    "tryRatingTriggerCount": 30,    // 试用多少次后触发评分
    "ratedTriggerCount": 100        // 已评分用户多少次后再次提醒
  }
}
```

配置参数说明：

- **needPurchase**：控制是否启用内购功能
- **hidePurchaseEntry**：是否隐藏应用内的购买入口
- **tryRatingTriggerCount**：用户使用多少次后显示评分提醒
- **ratedTriggerCount**：已评分用户在多少次使用后再次显示评分提醒

## 核心功能

### 购买管理

LWPurchase 基于 Apple 的 StoreKit 框架，提供了完整的购买流程管理：

#### StoreManager
负责与 App Store 通信，获取产品信息：

```objective-c
// 获取产品信息
[[StoreManager sharedInstance] fetchProductInformationForIds:@[IAPProductId]];

// 获取产品标题
NSString *title = [[StoreManager sharedInstance] titleMatchingProductIdentifier:IAPProductId];
```

#### StoreObserver
实现购买和恢复购买的监听：

```objective-c
// 购买产品
[[StoreObserver sharedInstance] buy:product];

// 恢复购买
[[StoreObserver sharedInstance] restore];

// 恢复指定产品
[[StoreObserver sharedInstance] restoreWithProduct:product];
```

#### 购买状态通知

监听购买状态变化：

```objective-c
// 监听内购通知
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(handlePurchaseNotification:)
                                             name:IAPPurchaseNotification
                                           object:nil];

- (void)handlePurchaseNotification:(NSNotification *)notification {
    StoreObserver *observer = [StoreObserver sharedInstance];

    switch (observer.status) {
        case IAPPurchaseSucceeded:
            // 购买成功
            break;
        case IAPPurchaseFailed:
            // 购买失败
            break;
        case IAPRestoredSucceeded:
            // 恢复成功
            break;
        case IAPRestoredFailed:
            // 恢复失败
            break;
        default:
            break;
    }
}
```

### 购买状态检查

使用 `LWPurchaseHelper` 类检查购买状态：

```objective-c
#import <LWPurchase/LWPurchaseHelper.h>

// 检查用户是否已购买
BOOL isPurchased = [LWPurchaseHelper isPurchased];

// 检查是否需要内购
BOOL needPurchase = [LWPurchaseHelper isNeedPurchase];

// 检查是否隐藏购买入口
BOOL hidePurchaseEntry = [LWPurchaseHelper hidePurchaseEntry];
```

### 价格显示

获取 App Store 中的产品价格：

```objective-c
// 重新加载应用价格
[LWPurchaseHelper reloadAppPriceWithCompleteBlock:^(double price) {
    NSLog(@"产品价格: ¥%.2f", price);
}];
```

### 评分功能

自动触发应用评分提醒：

```objective-c
// 显示评分界面
[LWPurchaseHelper showRating];
```

评分触发逻辑：
- 根据配置的 `tryRatingTriggerCount` 自动在适当时机显示评分提醒
- 已评分用户按 `ratedTriggerCount` 控制再次提醒频率

### UserDefaults 管理

LWPurchase 提供了便捷的数据持久化方法：

```objective-c
// 保存值（支持 App Group）
[LWPurchaseHelper setValue:@YES key:@"myKey"];

// 获取值（支持 App Group）
id value = [LWPurchaseHelper getValueByKey:@"myKey"];

// 使用 UserDefaults
[LWPurchaseHelper setUserDefaultValue:@YES withKey:@"myKey"];
id defaultValue = [LWPurchaseHelper getUserDefaultValueByKey:@"myKey"];
```

## 高级功能

### App Group 支持

如果您的应用包含 Extension（如键盘扩展、Today Widget 等），可以通过 App Group 在主应用和 Extension 之间共享内购状态：

1. 在 Xcode 中为主应用和 Extension 开启 App Groups 能力
2. 创建相同的 App Group ID（如 `group.com.yourcompany.yourapp`）
3. 在配置中设置 App Group ID：

```objective-c
#define AppGroupIdentifer @"group.com.yourcompany.yourapp"
```

这样，Extension 中就可以检查内购状态了。

### 日期判断工具

LWPurchase 提供了实用的日期判断方法：

```objective-c
// 判断当前日期是否在指定日期之后
BOOL isAfter = [LWPurchaseHelper isAfterDate:@"2024-01-01"];

// 计算两个日期之间的天数差
NSInteger days = [LWPurchaseHelper daysBetweenDate:@"2024-01-01"
                                           andDate:@"2024-12-31"];
```

### 界面定制

LWPurchase 提供了一组 UI 辅助工具：

```objective-c
// 显示提示信息
[MyPurchaseUIHelper showToastAlert:@"购买成功"];

// 显示 HUD 加载提示
[MyPurchaseUIHelper showHUDLoading];
[MyPurchaseUIHelper hideHUDLoading];

// 显示带消息的 HUD
[MyPurchaseUIHelper showHUDWithMessage:@"正在处理..."];

// 获取屏幕尺寸
CGSize screenSize = [MyPurchaseUIHelper fixedScreenSize];

// 检查是否已购买
BOOL isPurchased = [MyPurchaseUIHelper checkIsPurchase];
```

## 架构设计

### 核心类说明

#### 1. LWPurchaseViewController
- 主界面控制器，提供内购界面
- 管理购买、恢复购买按钮
- 处理用户交互和界面更新

#### 2. StoreManager
- 产品信息管理器
- 与 App Store 通信获取产品详情
- 实现 `SKProductsRequestDelegate` 协议
- 提供产品查询和信息获取接口

#### 3. StoreObserver
- 交易观察者
- 实现 `SKPaymentTransactionObserver` 协议
- 处理购买、恢复购买的完整流程
- 管理交易状态和通知

#### 4. LWPurchaseHelper
- 工具类，提供辅助功能
- 购买状态检查
- 配置文件管理
- 数据持久化
- 评分管理

#### 5. MyPurchaseUIHelper
- UI 辅助工具类
- HUD 显示管理
- 提示信息显示
- 界面相关工具方法

### 通知机制

LWPurchase 使用 NSNotification 进行状态通知：

**IAPPurchaseNotification**：购买相关通知
- `IAPPurchaseSucceeded`：购买成功
- `IAPPurchaseFailed`：购买失败
- `IAPRestoredSucceeded`：恢复成功
- `IAPRestoredFailed`：恢复失败
- `IAPDownloadStarted`：下载开始
- `IAPDownloadInProgress`：下载中
- `IAPDownloadSucceeded`：下载成功
- `IAPDownloadFailed`：下载失败

**IAPProductRequestNotification**：产品请求通知
- `IAPProductsFound`：找到有效产品
- `IAPIdentifiersNotFound`：产品 ID 无效
- `IAPProductRequestResponse`：请求响应
- `IAPRequestFailed`：请求失败

## 依赖项

LWPurchase 依赖以下第三方库：

- **FCAlertView**：美观的提示框组件
- **Masonry**：自动布局框架
- **Reachability**：网络状态检测
- **LWHUD**：加载提示框组件

这些依赖会在使用 CocoaPods 或 Carthage 安装时自动处理。

## 示例项目

要运行示例项目：

1. 克隆仓库：
```bash
git clone https://github.com/luowei/LWPurchase.git
cd LWPurchase/Example
```

2. 安装依赖：
```bash
pod install
```

3. 打开工作空间：
```bash
open LWPurchase.xcworkspace
```

4. 在 `LWPurchaseViewController.h` 中配置您的测试 Product ID

5. 运行项目

## 注意事项

### 1. 沙盒测试

- 在开发阶段，需要使用沙盒测试账号进行测试
- 在 App Store Connect 中创建沙盒测试账号
- 测试时需要退出正式的 Apple ID，使用沙盒账号登录

### 2. Product ID 配置

- Product ID 必须与 App Store Connect 中配置的完全一致
- 建议使用反向域名格式：`com.company.appname.productname`
- 非消耗型产品的 Product ID 通常使用 `_NoAds`、`_Premium` 等后缀

### 3. 配置文件

- 建议将配置文件放在自己的服务器上，便于动态调整
- 配置文件使用 JSON 格式，确保格式正确
- 可以通过远程配置控制内购功能的开关

### 4. 恢复购买

- 非消耗型产品必须提供恢复购买功能
- 用户换设备或重装应用后可以免费恢复已购买的产品
- Apple 审核要求必须在明显位置提供恢复购买入口

### 5. 隐私和安全

- 购买记录存储在本地 UserDefaults 中
- 如果需要更高的安全性，建议增加服务器端验证
- 使用 App Group 时注意数据安全

### 6. 本地化

LWPurchase 已内置多语言支持：
- 中文简体 (zh-Hans)
- 中文繁体 (zh-Hant)
- 英文 (en)
- 日文 (ja)

界面会根据系统语言自动切换。

## 常见问题

### Q: 为什么购买后没有响应？

A: 请检查：
1. Product ID 配置是否正确
2. App Store Connect 中产品是否已配置并通过审核
3. 是否在真机或模拟器上使用沙盒账号测试
4. 网络连接是否正常

### Q: 如何验证购买是否成功？

A: 监听 `IAPPurchaseNotification` 通知，或使用：
```objective-c
BOOL purchased = [LWPurchaseHelper isPurchased];
```

### Q: 恢复购买没有反应？

A: 确保：
1. 该 Product ID 之前确实购买过
2. 使用购买时的同一个 Apple ID
3. 产品类型为非消耗型

### Q: 如何自定义界面？

A: 您可以：
1. 修改 `IAPConfig.json` 中的配置
2. 替换 Assets 中的图片资源
3. 继承 `LWPurchaseViewController` 并重写相关方法
4. 使用 `StoreManager` 和 `StoreObserver` 自己实现界面

### Q: 支持订阅型产品吗？

A: LWPurchase 主要针对非消耗型产品设计，不建议用于订阅型产品。订阅型产品有不同的处理逻辑和续订机制。

## 更新日志

### Version 1.0.0
- 初始版本发布
- 支持非消耗型产品购买
- 支持恢复购买
- 提供完整的 UI 界面
- 支持远程配置
- 支持 App Group
- 内置多语言支持
- 集成评分功能

## 贡献

欢迎提交 Issue 和 Pull Request！

如果您在使用过程中发现 Bug 或有新功能建议，请：
1. 在 GitHub 上提交 Issue
2. Fork 本项目
3. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
4. 提交您的修改 (`git commit -m 'Add some AmazingFeature'`)
5. 推送到分支 (`git push origin feature/AmazingFeature`)
6. 提交 Pull Request

## 作者

**luowei**
Email: luowei@wodedata.com

## 许可证

LWPurchase 基于 MIT 许可证开源。详见 [LICENSE](LICENSE) 文件。

```
Copyright (c) 2019 luowei <luowei@wodedata.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

## 相关链接

- [GitHub 仓库](https://github.com/luowei/LWPurchase)
- [CocoaPods 主页](https://cocoapods.org/pods/LWPurchase)
- [Apple StoreKit 文档](https://developer.apple.com/documentation/storekit)
- [App Store Connect](https://appstoreconnect.apple.com/)

## 致谢

感谢以下开源项目：
- FCAlertView
- Masonry
- Reachability
- LWHUD

---

如有任何问题或建议，欢迎联系作者或提交 Issue。
