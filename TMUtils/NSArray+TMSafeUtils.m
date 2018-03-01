//
//  NSArray+TMSafeUtils.m
//  TMUtils
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "NSArray+TMSafeUtils.h"
#import "NSString+TMSafeUtils.h"

@implementation NSArray (TMSafeUtils)

- (id)tm_safeObjectAtIndex:(NSUInteger)index
{
    if (index >= [self count]) {
        return nil;
    }
    id value = [self objectAtIndex:index];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

- (id)tm_safeObjectAtIndex:(NSUInteger)index class:(Class)aClass
{
    id value = [self tm_safeObjectAtIndex:index];
    if ([value isKindOfClass:aClass]) {
        return value;
    }
    return nil;
}

- (bool)tm_boolAtIndex:(NSUInteger)index
{
    id value = [self tm_safeObjectAtIndex:index];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value boolValue];
    }
    return NO;
}

- (CGFloat)tm_floatAtIndex:(NSUInteger)index
{
    id value = [self tm_safeObjectAtIndex:index];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value floatValue];
    }
    return 0;
}

- (NSInteger)tm_integerAtIndex:(NSUInteger)index
{
    id value = [self tm_safeObjectAtIndex:index];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value integerValue];
    }
    return 0;
}

- (int)tm_intAtIndex:(NSUInteger)index
{
    id value = [self tm_safeObjectAtIndex:index];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value intValue];
    }
    return 0;
}

- (long)tm_longAtIndex:(NSUInteger)index
{
    id value = [self tm_safeObjectAtIndex:index];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value longValue];
    }
    return 0;
}

- (NSNumber *)tm_numberAtIndex:(NSUInteger)index
{
    id value = [self tm_safeObjectAtIndex:index];
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    if ([value respondsToSelector:@selector(numberValue)]) {
        return [value numberValue];
    }
    return nil;
}

- (NSString *)tm_stringAtIndex:(NSUInteger)index
{
    id value = [self tm_safeObjectAtIndex:index];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    return nil;
}

- (NSArray *)tm_arrayAtIndex:(NSUInteger)index
{
    return [self tm_safeObjectAtIndex:index class:[NSArray class]];
}

- (NSDictionary *)tm_dictionaryAtIndex:(NSUInteger)index
{
    return [self tm_safeObjectAtIndex:index class:[NSDictionary class]];
}

- (NSMutableArray *)tm_mutableArrayAtIndex:(NSUInteger)index
{
    return [self tm_safeObjectAtIndex:index class:[NSMutableArray class]];
}

- (NSMutableDictionary *)tm_mutableDictionaryAtIndex:(NSUInteger)index
{
    return [self tm_safeObjectAtIndex:index class:[NSMutableDictionary class]];
}

@end

@implementation NSMutableArray (TMSafeUtils)

- (void)tm_safeAddObject:(id)anObject
{
    if (anObject) {
        [self addObject:anObject];
    }
}

- (void)tm_safeInsertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (anObject && index <= self.count) {
        [self insertObject:anObject atIndex:index];
    }
}

- (void)tm_safeReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (anObject && index < self.count) {
        [self replaceObjectAtIndex:index withObject:anObject];
    }
}

- (void)tm_safeRemoveObjectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        [self removeObjectAtIndex:index];
    }
}

- (void)tm_safeRemoveObject:(id)anObject
{
    if (anObject != nil) {
        [self removeObject:anObject];
    }
}

@end

