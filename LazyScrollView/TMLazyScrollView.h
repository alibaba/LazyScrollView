//
//  TMLazyScrollView.h
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMLazyItemModel.h"

@class TMLazyScrollView;

@protocol TMLazyScrollViewDataSource <NSObject>

@required

/**
 Similar with 'tableView:numberOfRowsInSection:' of UITableView.
 */
- (NSUInteger)numberOfItemsInScrollView:(nonnull TMLazyScrollView *)scrollView;

/**
 Similar with 'tableView:heightForRowAtIndexPath:' of UITableView.
 Manager the correct muiID of item views will bring a higher performance.
 */
- (nonnull TMLazyItemModel *)scrollView:(nonnull TMLazyScrollView *)scrollView
                       itemModelAtIndex:(NSUInteger)index;

/**
 Similar with 'tableView:cellForRowAtIndexPath:' of UITableView.
 It will use muiID in item model instead of index.
 */
- (nonnull UIView *)scrollView:(nonnull TMLazyScrollView *)scrollView
                   itemByMuiID:(nonnull NSString *)muiID;

@end

//****************************************************************

@interface TMLazyScrollView : UIScrollView

// 注意，修改 delegate 属性后需要将 scrollViewDidScroll: 事件转发回给 TangramView

@property (nonatomic, weak, nullable) id<TMLazyScrollViewDataSource> dataSource;

@property (nonatomic, weak, nullable) id<UIScrollViewDelegate> forwardingDelegate;

// Default value is NO.
@property (nonatomic, assign) BOOL autoAddSubview;

// Items which has been added to LazyScrollView.
@property (nonatomic, strong, readonly, nonnull) NSSet<UIView *> *visibleItems;
// Items which is in the visible screen area.
// It is a sub set of "visibleItems".
@property (nonatomic, strong, readonly, nonnull) NSSet<UIView *> *inScreenVisibleItems;
// Tangram can be footerView for TableView, this outerScrollView is your tableview.
@property (nonatomic, weak, nullable) UIScrollView *outerScrollView;


// reloads everything from scratch and redisplays visible views.
- (void)reloadData;
// Remove all subviews and reuseable views.
- (void)removeAllLayouts;

// Get reuseable view by reuseIdentifier. If cannot find reuseable
// view by reuseIdentifier, here will return nil.
- (nullable UIView *)dequeueReusableItemWithIdentifier:(nonnull NSString *)identifier;
// Get reuseable view by reuseIdentifier and muiID.
// MuiID has higher priority.
- (nullable UIView *)dequeueReusableItemWithIdentifier:(nonnull NSString *)identifier
                                                 muiID:(nullable NSString *)muiID;

// After call this method, the times of mui_didEnterWithTimes will start from 0
- (void)resetViewEnterTimes;

@end

//****************************************************************

@interface TMLazyScrollViewObserver: NSObject
@property (nonatomic, weak, nullable) TMLazyScrollView *lazyScrollView;
@end
