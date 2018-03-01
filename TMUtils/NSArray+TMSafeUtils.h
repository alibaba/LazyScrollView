//
//  NSArray+TMSafeUtils.h
//  TMUtils
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSArray (TMSafeUtils)

- (id)tm_safeObjectAtIndex:(NSUInteger)index;
- (id)tm_safeObjectAtIndex:(NSUInteger)index class:(Class)aClass;

- (bool)tm_boolAtIndex:(NSUInteger)index;
- (CGFloat)tm_floatAtIndex:(NSUInteger)index;
- (NSInteger)tm_integerAtIndex:(NSUInteger)index;
- (int)tm_intAtIndex:(NSUInteger)index;
- (long)tm_longAtIndex:(NSUInteger)index;
- (NSNumber *)tm_numberAtIndex:(NSUInteger)index;
- (NSString *)tm_stringAtIndex:(NSUInteger)index;
- (NSDictionary *)tm_dictionaryAtIndex:(NSUInteger)index;
- (NSArray *)tm_arrayAtIndex:(NSUInteger)index;
- (NSMutableDictionary *)tm_mutableDictionaryAtIndex:(NSUInteger)index;
- (NSMutableArray *)tm_mutableArrayAtIndex:(NSUInteger)index;

@end

@interface NSMutableArray (TMSafeUtils)

- (void)tm_safeAddObject:(id)anObject;
- (void)tm_safeInsertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)tm_safeReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (void)tm_safeRemoveObjectAtIndex:(NSUInteger)index;
- (void)tm_safeRemoveObject:(id)anObject;

@end
