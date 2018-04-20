//
//  NSDictionary+TMSafeUtils.h
//  TMUtils
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSDictionary (TMSafeUtils)

- (id)tm_safeObjectForKey:(id)key;
- (id)tm_safeObjectForKey:(id)key class:(Class)aClass;

- (bool)tm_boolForKey:(id)key;
- (CGFloat)tm_floatForKey:(id)key;
- (NSInteger)tm_integerForKey:(id)key;
- (int)tm_intForKey:(id)key;
- (long)tm_longForKey:(id)key;
- (NSNumber *)tm_numberForKey:(id)key;
- (NSString *)tm_stringForKey:(id)key;
- (NSDictionary *)tm_dictionaryForKey:(id)key;
- (NSArray *)tm_arrayForKey:(id)key;
- (NSMutableDictionary *)tm_mutableDictionaryForKey:(id)key;
- (NSMutableArray *)tm_mutableArrayForKey:(id)key;

@end

@interface NSMutableDictionary (TMSafeUtils)

- (void)tm_safeSetObject:(id)anObject forKey:(id)key;
- (void)tm_safeRemoveObjectForKey:(id)key;

@end
