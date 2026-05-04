# Graph Report - /Users/luowei/projects/libs/LWPurchase  (2026-05-04)

## Corpus Check
- Corpus is ~19,722 words - fits in a single context window. You may not need a graph.

## Summary
- 286 nodes · 341 edges · 17 communities detected
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 2 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]

## God Nodes (most connected - your core abstractions)
1. `LWPurchaseViewController` - 29 edges
2. `StoreObserver` - 24 edges
3. `LWPurchaseView` - 22 edges
4. `LWPurchaseHelper` - 18 edges
5. `LWPurchaseHelper` - 18 edges
6. `LWPurchase` - 16 edges
7. `StoreManager` - 15 edges
8. `LWPurchaseManager` - 14 edges
9. `LWPurchaseUIHelper` - 12 edges
10. `MyPurchaseUIHelper` - 12 edges

## Surprising Connections (you probably didn't know these)
- `LWPurchaseView` --inherits--> `View`  [EXTRACTED]
  LWPurchase_swift/Swift/LWPurchaseView.swift →   _Bridges community 5 → community 3_
- `LWPurchaseManager` --inherits--> `ObservableObject`  [EXTRACTED]
  LWPurchase_swift/Swift/LWPurchaseManager.swift →   _Bridges community 11 → community 8_
- `StoreObserver` --inherits--> `NSObject`  [EXTRACTED]
  LWPurchase/Classes/InAppPurchase/StoreObserver.m →   _Bridges community 12 → community 4_
- `StoreManager` --inherits--> `NSObject`  [EXTRACTED]
  LWPurchase/Classes/InAppPurchase/StoreManager.m →   _Bridges community 12 → community 1_

## Communities (24 total, 3 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.07
Nodes (29): LWPurchaseViewController, -buyAction, -dataList, -fetchProductInformation, -handleDismiss, -handleProductRequestNotification, -handlePurchasesNotification, -isSimulator (+21 more)

### Community 1 - "Community 1"
Cohesion: 0.08
Nodes (19): IAPProductRequestStatus, identifiersNotFound, productRequestResponse, productsFound, requestFailed, MyModel, -init, -initWithNameelements (+11 more)

### Community 2 - "Community 2"
Cohesion: 0.08
Nodes (9): Error, LWPurchase, LWPurchaseError, cannotMakePayments, productNotFound, purchaseFailed, restoreFailed, unknown (+1 more)

### Community 3 - "Community 3"
Cohesion: 0.18
Nodes (4): Identifiable, LWPurchaseView, PurchaseItem, PurchaseSection

### Community 4 - "Community 4"
Cohesion: 0.1
Nodes (19): StoreObserver, -buy, -completeTransactionforStatus, -dealloc, -finishDownloadTransaction, -hasPurchasedProducts, -hasRestoredProducts, -init (+11 more)

### Community 5 - "Community 5"
Cohesion: 0.12
Nodes (16): App, ButtonStyle, PreviewProvider, AdvancedExampleView, BasicExampleView, ContentView, ContentView_Previews, ModernExampleView (+8 more)

### Community 7 - "Community 7"
Cohesion: 0.11
Nodes (18): LWPurchaseHelper, -daysBetweenDateandDate, -getMyInputMethodAPPGroupValueByKey, -getUserDefaultValueByKey, -getValueByKey, -hidePurchaseEntry, -isAfterDate, -isNeedPurchase (+10 more)

### Community 9 - "Community 9"
Cohesion: 0.21
Nodes (3): UIKitExampleViewController, LWPurchaseViewController, UIViewController

### Community 10 - "Community 10"
Cohesion: 0.15
Nodes (12): MyPurchaseUIHelper, -checkIsPurchase, -createIfNotExistsDirectory, -fixedScreenSize, -hideHUDLoading, -iCloudBackupPathskip, -icloudDocumentURL, -showHUDLoading (+4 more)

### Community 11 - "Community 11"
Cohesion: 0.2
Nodes (3): ObservableObject, CallbackExample, PurchaseViewModel

### Community 13 - "Community 13"
Cohesion: 0.18
Nodes (10): IAPPurchaseNotificationStatus, downloadFailed, downloadInProgress, downloadStarted, downloadSucceeded, purchaseFailed, purchaseSucceeded, restoredFailed (+2 more)

### Community 14 - "Community 14"
Cohesion: 0.25
Nodes (7): LWAppDelegate, -applicationDidBecomeActive, -applicationDidEnterBackground, -applicationdidFinishLaunchingWithOptions, -applicationWillEnterForeground, -applicationWillResignActive, -applicationWillTerminate

### Community 15 - "Community 15"
Cohesion: 0.33
Nodes (3): LWPurchaseBundleHelper, LWPurchaseKeys, LWPurchaseURLs

### Community 16 - "Community 16"
Cohesion: 0.4
Nodes (4): LWViewController, -btnAction, -didReceiveMemoryWarning, -viewDidLoad

## Knowledge Gaps
- **110 isolated node(s):** `-applicationdidFinishLaunchingWithOptions`, `-applicationWillResignActive`, `-applicationDidEnterBackground`, `-applicationWillEnterForeground`, `-applicationDidBecomeActive` (+105 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `LWPurchaseUIHelper` connect `Community 12` to `Community 9`?**
  _High betweenness centrality (0.206) - this node is a cross-community bridge._
- **Why does `LWPurchaseView` connect `Community 3` to `Community 9`, `Community 2`, `Community 5`?**
  _High betweenness centrality (0.189) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `LWPurchaseView` (e.g. with `.purchaseView()` and `.setupHostingController()`) actually correct?**
  _`LWPurchaseView` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `-applicationdidFinishLaunchingWithOptions`, `-applicationWillResignActive`, `-applicationDidEnterBackground` to the rest of the system?**
  _110 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._