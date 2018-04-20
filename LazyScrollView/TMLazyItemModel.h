//
//  TMLazyItemModel.h
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 It is a model to store data of item view.
 */
@interface TMLazyItemModel : NSObject

/**
 Item view's frame in LazyScrollView.
 */
@property (nonatomic, assign) CGRect absRect;
@property (nonatomic, readonly) CGFloat top;
@property (nonatomic, readonly) CGFloat bottom;

/**
 Item view's unique ID in LazyScrollView.
 Will be set to string value of index if it's nil.
 The ID MUST BE unique.
 */
@property (nonatomic, copy) NSString *muiID;

@end
