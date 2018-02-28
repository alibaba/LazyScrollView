//
//  NSDictionary+TMSafeUtils.m
//  TMUtils
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "NSDictionary+TMSafeUtils.h"
#import "NSString+TMSafeUtils.h"

@implementation NSDictionary (TMSafeUtils)

- (id)tm_safeObjectForKey:(id)key
{
    if (key == nil) {
        return nil;
    }
    id value = [self objectForKey:key];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

- (id)tm_safeObjectForKey:(id)key class:(Class)aClass
{
    id value = [self tm_safeObjectForKey:key];
    if ([value isKindOfClass:aClass]) {
        return value;
    }
    return nil;
}

- (bool)tm_boolForKey:(id)key
{
    id value = [self tm_safeObjectForKey:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value boolValue];
    }
    return NO;
}

- (CGFloat)tm_floatForKey:(id)key
{
    id value = [self tm_safeObjectForKey:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value floatValue];
    }
    return 0;
}

- (NSInteger)tm_integerForKey:(id)key
{
    id value = [self tm_safeObjectForKey:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value integerValue];
    }
    return 0;
}

- (int)tm_intForKey:(id)key
{
    id value = [self tm_safeObjectForKey:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value intValue];
    }
    return 0;
}

- (long)tm_longForKey:(id)key
{
    id value = [self tm_safeObjectForKey:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value longValue];
    }
    return 0;
}

- (NSNumber *)tm_numberForKey:(id)key
{
    id value = [self tm_safeObjectForKey:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    if ([value respondsToSelector:@selector(numberValue)]) {
        return [value numberValue];
    }
    return nil;
}

- (NSString *)tm_stringForKey:(id)key
{
    id value = [self tm_safeObjectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    return nil;
}

- (NSArray *)tm_arrayForKey:(id)key
{
    return [self tm_safeObjectForKey:key class:[NSArray class]];
}

- (NSDictionary *)tm_dictionaryForKey:(id)key
{
    return [self tm_safeObjectForKey:key class:[NSDictionary class]];
}

- (NSMutableArray *)tm_mutableArrayForKey:(id)key
{
    return [self tm_safeObjectForKey:key class:[NSMutableArray class]];
}

- (NSMutableDictionary *)tm_mutableDictionaryForKey:(id)key
{
    return [self tm_safeObjectForKey:key class:[NSMutableDictionary class]];
}

@end

@implementation NSMutableDictionary (TMSafeUtils)

- (void)tm_safeSetObject:(id)anObject forKey:(id)key
{
    if (key && anObject) {
        [self setObject:anObject forKey:key];
    }
}

-(void)tm_safeRemoveObjectForKey:(id)key
{
    if (key) {
        [self removeObjectForKey:key];
    }
}

@end

