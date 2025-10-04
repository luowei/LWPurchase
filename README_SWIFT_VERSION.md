# LWPurchase Swift版本使用说明

## 概述

LWPurchase提供了Swift版本的实现，专门为使用Swift开发的项目优化，提供更现代化的API和SwiftUI支持。

## 安装

### CocoaPods

在你的`Podfile`中添加：

```ruby
pod 'LWPurchase_swift'
```

然后运行：

```bash
pod install
```

## 要求

- iOS 13.0+
- Swift 5.0+
- Xcode 12.0+

## Swift版本包含的功能

Swift版本包含以下组件：

- `LWPurchaseConfig.swift` - 购买配置
- `LWPurchaseHelper.swift` - 购买辅助类
- `StoreManager.swift` - 商店管理器
- `StoreObserver.swift` - 商店观察者
- `LWPurchaseView.swift` - 购买视图
- `LWPurchaseViewController.swift` - 购买视图控制器
- `LWPurchaseManager.swift` - 购买管理器
- `ModernPurchaseView.swift` - 现代化购买视图
- `LWPurchase.swift` - 主入口
- `ExampleApp.swift` - 使用示例

## 使用示例

### 基础用法

```swift
import LWPurchase_swift

// 配置购买
let config = LWPurchaseConfig()
config.productID = "com.yourapp.product"

// 发起购买
LWPurchaseManager.shared.purchase(config: config) { result in
    switch result {
    case .success:
        print("购买成功")
    case .failure(let error):
        print("购买失败: \(error)")
    }
}
```

### SwiftUI集成

```swift
import SwiftUI
import LWPurchase_swift

struct ContentView: View {
    var body: some View {
        ModernPurchaseView()
    }
}
```

## 与Objective-C版本的区别

- Swift版本要求iOS 13.0+（Objective-C版本支持iOS 8.0+）
- Swift版本提供了SwiftUI支持
- Swift版本使用现代Swift语法和Combine框架
- 提供更类型安全的API

## 注意事项

- 如果你的项目同时使用Objective-C和Swift，可以同时安装`LWPurchase`和`LWPurchase_swift`
- Swift版本与Objective-C版本可以共存，互不影响
- 确保在App Store Connect中正确配置了内购产品

## 许可证

LWPurchase_swift遵循MIT许可证。详见LICENSE文件。
