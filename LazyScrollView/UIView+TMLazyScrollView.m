//
//  UIView+TMLazyScrollView.m
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "UIView+TMLazyScrollView.h"
#import <objc/runtime.h>

#define ReuseIdentifierKey @"ReuseIdentifierKey"
#define MuiIdKey @"MuiIdKey"

@implementation UIView (TMLazyScrollView)

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [self init]) {
        self.reuseIdentifier = reuseIdentifier;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [self initWithFrame:frame]) {
        self.reuseIdentifier = reuseIdentifier;
    }
    return self;
}

- (NSString *)reuseIdentifier
{
    return objc_getAssociatedObject(self, ReuseIdentifierKey);
}

- (void)setReuseIdentifier:(NSString *)reuseIdentifier
{
    objc_setAssociatedObject(self, ReuseIdentifierKey, reuseIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)muiID
{
    return objc_getAssociatedObject(self, MuiIdKey);
}

- (void)setMuiID:(NSString *)muiID
{
    objc_setAssociatedObject(self, MuiIdKey, muiID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
