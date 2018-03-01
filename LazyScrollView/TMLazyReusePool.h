//
//  TMLazyReusePool.h
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMLazyReusePool : NSObject

- (void)addItemView:(UIView *)itemView forReuseIdentifier:(NSString *)reuseIdentifier;
- (UIView *)dequeueItemViewForReuseIdentifier:(NSString *)reuseIdentifier;
- (UIView *)dequeueItemViewForReuseIdentifier:(NSString *)reuseIdentifier andMuiID:(NSString *)muiID;
- (void)clear;

@end
