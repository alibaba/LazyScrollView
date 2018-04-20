//
//  TMLazyItemViewProtocol.h
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

/**
 If the item view in LazyScrollView implements this protocol, it
 can receive specified event callback in LazyScrollView's lifecycle.
 */
@protocol TMLazyItemViewProtocol <NSObject>

@optional
/**
 Will be called if the item view is dequeued in
 'dequeueReusableItemWithIdentifier:' method.
 It is similar with 'prepareForReuse' method of UITableViewCell.
 */
- (void)mui_prepareForReuse;
/**
 Will be called if the item view is loaded into buffer area.
 This callback always is used for setup item view.
 It is similar with 'viewDidLoad' method of UIViewController.
 */
- (void)mui_afterGetView;
/**
 Will be called if the item view enters the visible area.
 The times starts from 0.
 If the item view is in the visible area and the LazyScrollView
 is reloaded, this callback will not be called.
 This callback always is used for user action tracking. Sometimes,
 it is also used for starting timer event.
 */
- (void)mui_didEnterWithTimes:(NSUInteger)times;
/**
 Will be called if the item view leaves the visiable area.
 This callback always is used for stopping timer event.
 */
- (void)mui_didLeave;

@end
