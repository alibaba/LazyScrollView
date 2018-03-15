//
//  TMLazyModelBucket.h
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMLazyItemModel.h"

/**
 Every bucket store item models in an area.
 1st bucket store item models which Y value is from 0 to bucketHeight.
 2nd bucket store item models which Y value is from bucketHeight to bucketHeight * 2.
 */
@interface TMLazyModelBucket : NSObject

@property (nonatomic, assign, readonly) CGFloat bucketHeight;

- (instancetype)initWithBucketHeight:(CGFloat)bucketHeight;

- (void)addModel:(TMLazyItemModel *)itemModel;
- (void)addModels:(NSSet<TMLazyItemModel *> *)itemModels;
- (void)removeModel:(TMLazyItemModel *)itemModel;
- (void)removeModels:(NSSet<TMLazyItemModel *> *)itemModels;
- (void)reloadModel:(TMLazyItemModel *)itemModel;
- (void)reloadModels:(NSSet<TMLazyItemModel *> *)itemModels;
- (void)clear;
- (NSSet<TMLazyItemModel *> *)showingModelsFrom:(CGFloat)startY to:(CGFloat)endY;

@end
