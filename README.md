[![CocoaPods](https://img.shields.io/cocoapods/v/LazyScroll.svg)]() [![CocoaPods](https://img.shields.io/cocoapods/p/LazyScroll.svg)]() [![CocoaPods](https://img.shields.io/cocoapods/l/LazyScroll.svg)]()

# LazyScrollView

[中文说明](http://pingguohe.net/2016/01/31/lazyscroll.html) [中文Demo说明](http://pingguohe.net/2017/03/02/lazyScrollView-demo.html)

> 依赖 LazyScrollView，我们创建了一个模块化页面UI解决方案，详情可见 [Tangram-iOS](https://github.com/alibaba/tangram-ios)。

LazyScrollView is an iOS ScrollView, to resolve the problem of reusability of views.

We reply another way to control reuse in a ScrollView, it depends on give a special reuse identifier to every view controlled in LazyScrollView.

Comparing to UITableView, LazyScrollView can easily create different layout, instead of the single row flow layout.

Comparing to UICollectionView, LazyScrollView can create views without Grid layout, and provides a easier way to create different kinds of layous in a ScrollView.

The system requirement is iOS 5+.

> We create a modular UI solution for building native page dynamically based on `LazyScrollView`, you can see more info from this repo: [Tangram-iOS](https://github.com/alibaba/tangram-ios)

# Installation

LazyScroll is available as `LazyScroll` in CocoaPods.

    pod 'LazyScroll'

If you don't want to use cocoapods, you can also manually add the files in `LazyScrollView` folder into your Xcode project.

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

To view detailed usage, please clone the repo and open the demo project. 
