//
//  TMLazyModelBucket.m
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "TMLazyModelBucket.h"

@interface TMLazyModelBucket () {
    NSMutableArray<NSMutableSet *> *_buckets;
}

@end

@implementation TMLazyModelBucket

@synthesize bucketHeight = _bucketHeight;

- (instancetype)initWithBucketHeight:(CGFloat)bucketHeight
{
    if (self = [super init]) {
        _bucketHeight = bucketHeight;
        _buckets = [NSMutableArray array];
    }
    return self;
}

- (void)addModel:(TMLazyItemModel *)itemModel
{
    if (itemModel && itemModel.bottom > itemModel.top) {
        NSInteger startIndex = (NSInteger)floor(itemModel.top / _bucketHeight);
        NSInteger endIndex = (NSInteger)floor((itemModel.bottom - 0.01) / _bucketHeight);
        for (NSInteger index = 0; index <= endIndex; index++) {
            if (_buckets.count <= index) {
                [_buckets addObject:[NSMutableSet set]];
            }
            if (index >= startIndex && index <= endIndex) {
                NSMutableSet *bucket = [_buckets objectAtIndex:index];
                [bucket addObject:itemModel];
            }
        }
    }
}

- (void)addModels:(NSSet<TMLazyItemModel *> *)itemModels
{
    if (itemModels) {
        for (TMLazyItemModel *itemModel in itemModels) {
            [self addModel:itemModel];
        }
    }
}

- (void)removeModel:(TMLazyItemModel *)itemModel
{
    if (itemModel) {
        for (NSMutableSet *bucket in _buckets) {
            [bucket removeObject:itemModel];
        }
    }
}

- (void)removeModels:(NSSet<TMLazyItemModel *> *)itemModels
{
    if (itemModels) {
        for (NSMutableSet *bucket in _buckets) {
            [bucket minusSet:itemModels];
        }
    }
}

- (void)reloadModel:(TMLazyItemModel *)itemModel
{
    [self removeModel:itemModel];
    [self addModel:itemModel];
}

- (void)reloadModels:(NSSet<TMLazyItemModel *> *)itemModels
{
    [self removeModels:itemModels];
    [self addModels:itemModels];
}

- (void)clear
{
    [_buckets removeAllObjects];
}

- (NSSet<TMLazyItemModel *> *)showingModelsFrom:(CGFloat)startY to:(CGFloat)endY
{
    NSMutableSet *result = [NSMutableSet set];
    NSInteger startIndex = (NSInteger)floor(startY / _bucketHeight);
    NSInteger endIndex = (NSInteger)floor((endY - 0.01) / _bucketHeight);
    for (NSInteger index = 0; index <= endIndex; index++) {
        if (_buckets.count > index && index >= startIndex && index <= endIndex) {
            NSSet *bucket = [_buckets objectAtIndex:index];
            [result unionSet:bucket];
        }
    }
    NSMutableSet *needToBeRemoved = [NSMutableSet set];
    for (TMLazyItemModel *itemModel in result) {
        if (itemModel.top >= endY || itemModel.bottom <= startY) {
            [needToBeRemoved addObject:itemModel];
        }
    }
    [result minusSet:needToBeRemoved];
    return [result copy];
}

@end
