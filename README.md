[![CocoaPods](https://img.shields.io/cocoapods/v/LazyScroll.svg)]() [![CocoaPods](https://img.shields.io/cocoapods/p/LazyScroll.svg)]() [![CocoaPods](https://img.shields.io/cocoapods/l/LazyScroll.svg)]()

# LazyScrollView

[中文说明](http://pingguohe.net/2016/01/31/lazyscroll.html)

> 基于 LazyScrollView，我们创造了一个动态创建模块化 UI 页面的解决方案，详情可见 [Tangram-iOS](https://github.com/alibaba/tangram-ios)。

LazyScrollView is an iOS ScrollView, to resolve the problem of reusability of views.

Comparing to UITableView, LazyScrollView can easily create different layout, instead of the single row flow layout.

Comparing to UICollectionView, LazyScrollView can create views without Grid layout, and provides a easier way to create different kinds of layous in a ScrollView.

> We create a modular UI solution for building UI page dynamically based on `LazyScrollView`, you can see more info from this repo: [Tangram-iOS](https://github.com/alibaba/tangram-ios)

# Installation

LazyScroll is available as `LazyScroll` in CocoaPods.

    pod 'LazyScroll'

You can also download the source files from [release page](https://github.com/alibaba/LazyScrollView/releases) and add them into your project manually.

# Usage

    #import "TMMuiLazyScrollView.h"
    
Then, create LazyScrollView:
 
```objectivec
TMMuiLazyScrollView *scrollview = [[TMMuiLazyScrollView alloc]init];
scrollview.frame = self.view.bounds;
```

Next, implement `TMMuiLazyScrollViewDataSource`:
 
```objectivec
@protocol TMMuiLazyScrollViewDataSource <NSObject>

@required

// Number of items in scrollView.
- (NSUInteger)numberOfItemInScrollView:(TMMuiLazyScrollView *)scrollView;

// Return the view model (TMMuiRectModel) by index.
- (TMMuiRectModel *)scrollView:(TMMuiLazyScrollView *)scrollView rectModelAtIndex:(NSUInteger)index;

// Return view by the unique string that identify a model (muiID).
// You should render the item view here.
// You should ALWAYS try to reuse views by setting each view's reuseIdentifier.
- (UIView *)scrollView:(TMMuiLazyScrollView *)scrollView itemByMuiID:(NSString *)muiID;

@end
```

Next, set datasource of LazyScrollView:

```objectivec
scrollview.dataSource = self;
```

Finally, do reload:

```objectivec
[scrollview reloadData];
```

For more details, please clone the repo and open the demo project. 

# 微信群

![](https://img.alicdn.com/tfs/TB11_2_kbSYBuNjSspiXXXNzpXa-167-167.png)

搜索 `tangram_` 或者扫描以上二维码添加 Tangram 为好友，以便我们邀请你入群。
