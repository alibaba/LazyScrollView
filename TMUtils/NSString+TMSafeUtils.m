//
//  NSString+TMSafeUtils.m
//  TMUtils
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "NSString+TMSafeUtils.h"

@implementation NSString (TMSafeUtils)

- (long)longValue
{
    return (long)[self integerValue];
}

- (NSNumber *)numberValue
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    return [formatter numberFromString:self];
}

@end
