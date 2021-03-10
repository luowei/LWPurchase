# LWPurchase

[![CI Status](https://img.shields.io/travis/luowei/LWPurchase.svg?style=flat)](https://travis-ci.org/luowei/LWPurchase)
[![Version](https://img.shields.io/cocoapods/v/LWPurchase.svg?style=flat)](https://cocoapods.org/pods/LWPurchase)
[![License](https://img.shields.io/cocoapods/l/LWPurchase.svg?style=flat)](https://cocoapods.org/pods/LWPurchase)
[![Platform](https://img.shields.io/cocoapods/p/LWPurchase.svg?style=flat)](https://cocoapods.org/pods/LWPurchase)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Usage

```oc
//打开App内购页面
- (IBAction)btnAction:(UIButton *)sender {
    UINavigationController *navigation = [LWPurchaseViewController navigationViewController];
    [self presentViewController:navigation animated:YES completion:^{}];
}

```

注意：集成后把`LWPurchaseViewController.h`配置宏改成你自己的，
```
//todo: 改成你自己的 内购ProductId
#define IAPProductId (@"com.wodedata.Test_NoAds")   //内购ProductId

//把Assets目录底下的data_iapconfig.json，改成你自己的，并传到自己的私服上，并把地址配置给以下的IAPConfig_URLString
#define IAPConfig_URLString @"http://xxxxx.com/xxxx/data_iapconfig.json"

//如果Extension中也要同步内购信息，AppGroup配置一下即可
// #define AppGroupIdentifer @"group.com.wodedata.test"

```

## Requirements

## Installation

LWPurchase is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:  

```ruby
pod 'LWPurchase'
```

**Carthage**
```ruby
github "luowei/LWPurchase"
```


## Author

luowei, luowei@wodedata.com

## License

LWPurchase is available under the MIT license. See the LICENSE file for more info.
