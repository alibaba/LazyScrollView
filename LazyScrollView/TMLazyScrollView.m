//
//  TMLazyScrollView.m
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "TMLazyScrollView.h"
#import <objc/runtime.h>
#import "TMLazyItemViewProtocol.h"
#import "UIView+TMLazyScrollView.h"
#import "TMLazyReusePool.h"

#define LazyBufferHeight 20.0
void * const LazyObserverContext = "LazyObserverContext";

@interface TMLazyOuterScrollViewObserver: NSObject

@property (nonatomic, weak) TMLazyScrollView *lazyScrollView;

@end

//****************************************************************

@interface TMLazyScrollView () {
    NSMutableSet<UIView *> *_visibleItems;
    NSMutableSet<UIView *> *_inScreenVisibleItems;
    
    // Store item models.
    NSMutableArray<TMLazyItemModel *> *_itemModels;
    
    // Store view models below contentOffset of ScrollView
    NSMutableSet<TMLazyItemModel *> *_firstSet;
    // Store view models above contentOffset + height of ScrollView
    NSMutableSet<TMLazyItemModel *> *_secondSet;
    // View Model sorted by Top Edge.
    NSArray<TMLazyItemModel *> *_modelsSortedByTop;
    // View Model sorted by Bottom Edge.
    NSArray<TMLazyItemModel *> *_modelsSortedByBottom;
    
    // Store items which need to be reloaded.
    NSMutableSet<NSString *> *_needReloadingMuiIDs;
    
    // Record current muiID of reloading item.
    // Will be used for dequeueReusableItem methods.
    NSString *_currentReloadingMuiID;
    
    // Store the enter screen times of items.
    NSMutableDictionary<NSString *, NSNumber *> *_enterTimesDict;
    
    // Store visible models for the last time. Used for calc enter times.
    NSSet<TMLazyItemModel *> *_lastInScreenVisibleModels;

    // Record contentOffset of scrollview in previous time that
    // calculate views to show.
    CGPoint _lastContentOffset;
}

@property (nonatomic, strong) TMLazyOuterScrollViewObserver *outerScrollViewObserver;

- (void)outerScrollViewDidScroll;

@end

@implementation TMLazyScrollView

#pragma mark Getter & Setter

- (NSSet<UIView *> *)inScreenVisibleItems
{
    if (!_inScreenVisibleItems) {
        _inScreenVisibleItems = [NSMutableSet set];
        NSSet *lastInScreenVisibleMuiIDs = [_lastInScreenVisibleModels valueForKey:@"muiID"];
        for (UIView *view in _visibleItems) {
            if ([lastInScreenVisibleMuiIDs containsObject:view.muiID]) {
                [_inScreenVisibleItems addObject:view];
            }
        }
    }
    return [_inScreenVisibleItems copy];
}

- (NSSet<UIView *> *)visibleItems
{
    return [_visibleItems copy];
}

- (void)setDataSource:(id<TMLazyScrollViewDataSource>)dataSource
{
    if (_dataSource != dataSource) {
        if (dataSource == nil || [self isDataSourceValid:dataSource]) {
            _dataSource = dataSource;
#ifdef DEBUG
        } else {
            NSAssert(NO, @"TMLazyScrollView - Invalid dataSource.");
#endif
        }
    }
}

- (TMLazyOuterScrollViewObserver *)outerScrollViewObserver
{
    if (!_outerScrollViewObserver) {
        _outerScrollViewObserver = [TMLazyOuterScrollViewObserver new];
        _outerScrollViewObserver.lazyScrollView = self;
    }
    return _outerScrollViewObserver;
}

-(void)setOuterScrollView:(UIScrollView *)outerScrollView
{
    if (_outerScrollView != outerScrollView) {
        if (_outerScrollView) {
            [_outerScrollView removeObserver:self.outerScrollViewObserver forKeyPath:@"contentOffset" context:LazyObserverContext];
        }
        if (outerScrollView) {
            [outerScrollView addObserver:self.outerScrollViewObserver forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:LazyObserverContext];
        }
        _outerScrollView = outerScrollView;
    }
}

#pragma mark Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        _autoClearGestures = YES;
        
        _reusePool = [TMLazyReusePool new];
        
        _visibleItems = [[NSMutableSet alloc] init];
        
        _itemModels = [[NSMutableArray alloc] init];
        
        _firstSet = [[NSMutableSet alloc] initWithCapacity:30];
        _secondSet = [[NSMutableSet alloc] initWithCapacity:30];
        _modelsSortedByTop = [[NSArray alloc] init];
        _modelsSortedByBottom = [[NSArray alloc]init];
        
        _needReloadingMuiIDs = [[NSMutableSet alloc] init];
        
        _enterTimesDict = [[NSMutableDictionary alloc] init];
        _lastInScreenVisibleModels = [NSSet set];
    }
    return self;
}

- (void)dealloc
{
    self.dataSource = nil;
    self.delegate = nil;
    self.outerScrollView = nil;
}

#pragma mark ScrollEvent

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    if (LazyBufferHeight < ABS(contentOffset.y - _lastContentOffset.y)) {
        _lastContentOffset = self.contentOffset;
        [self assembleSubviews:NO];
    }
}

- (void)outerScrollViewDidScroll
{
    if (LazyBufferHeight < ABS(self.outerScrollView.contentOffset.y - _lastContentOffset.y)) {
        _lastContentOffset = self.outerScrollView.contentOffset;
        [self assembleSubviews:NO];
    }
}

#pragma mark CoreLogic

- (void)assembleSubviews:(BOOL)isReload
{
    if (self.outerScrollView) {
        CGRect visibleArea = CGRectIntersection(self.outerScrollView.bounds, self.frame);
        if (visibleArea.size.height > 0) {
            CGFloat offsetY = CGRectGetMinY(self.frame);
            CGFloat minY = CGRectGetMinY(visibleArea) - offsetY;
            CGFloat maxY = CGRectGetMaxY(visibleArea) - offsetY;
            [self assembleSubviews:isReload minY:minY maxY:maxY];
        } else {
            [self assembleSubviews:isReload minY:0 maxY:-LazyBufferHeight * 2];
        }
    } else {
        CGFloat minY = CGRectGetMinY(self.bounds);
        CGFloat maxY = CGRectGetMaxY(self.bounds);
        [self assembleSubviews:isReload minY:minY maxY:maxY];
    }
}

- (void)assembleSubviews:(BOOL)isReload minY:(CGFloat)minY maxY:(CGFloat)maxY
{
    // Calculate which item views should be shown.
    // Calculating will cost some time, so here is a buffer for reducing
    // times of calculating.
    NSSet<TMLazyItemModel *> *newVisibleModels = [self showingItemIndexSetFrom:minY - LazyBufferHeight
                                                                            to:maxY + LazyBufferHeight];
    NSSet<NSString *> *newVisibleMuiIDs = [newVisibleModels valueForKey:@"muiID"];

    // Find if item views are in visible area.
    // Recycle invisible item views.
    NSSet *visibleItemsCopy = [_visibleItems copy];
    for (UIView *itemView in visibleItemsCopy) {
        BOOL isToShow  = [newVisibleMuiIDs containsObject:itemView.muiID];
        if (!isToShow) {
            // Call didLeave.
            if ([itemView respondsToSelector:@selector(mui_didLeave)]){
                [(UIView<TMLazyItemViewProtocol> *)itemView mui_didLeave];
            }
            if (itemView.reuseIdentifier.length > 0) {
                itemView.hidden = YES;
                [self.reusePool addItemView:itemView forReuseIdentifier:itemView.reuseIdentifier];
                [_visibleItems removeObject:itemView];
            } else if(isReload && itemView.muiID) {
                [_needReloadingMuiIDs addObject:itemView.muiID];
            }
        } else if (isReload && itemView.muiID) {
            [_needReloadingMuiIDs addObject:itemView.muiID];
        }
    }
    
    // Generate or reload visible item views.
    for (NSString *muiID in newVisibleMuiIDs) {
        // 1. Item view is not visible. We should create or reuse an item view.
        // 2. Item view need to be reloaded.
        BOOL isVisible = [self isMuiIdVisible:muiID];
        BOOL needReload = [_needReloadingMuiIDs containsObject:muiID];
        if (isVisible == NO || needReload == YES) {
            if (self.dataSource) {
                // If you call dequeue method in your dataSource, the currentReloadingMuiID
                // will be used for searching the best-matched reusable view.
                if (isVisible) {
                    _currentReloadingMuiID = muiID;
                }
                UIView *itemView = [self.dataSource scrollView:self itemByMuiID:muiID];
                _currentReloadingMuiID = nil;
                // Call afterGetView.
                if ([itemView respondsToSelector:@selector(mui_afterGetView)]) {
                    [(UIView<TMLazyItemViewProtocol> *)itemView mui_afterGetView];
                }
                if (itemView) {
                    itemView.muiID = muiID;
                    itemView.hidden = NO;
                    if (![_visibleItems containsObject:itemView]) {
                        [_visibleItems addObject:itemView];
                    }
                    if (self.autoAddSubview) {
                        if (itemView.superview != self) {
                            [self addSubview:itemView];
                        }
                    }
                }
                [_needReloadingMuiIDs removeObject:muiID];
            }
        }
    }
    
    // Reset the inScreenVisibleItems.
    _inScreenVisibleItems = nil;
    
    // Calculate the inScreenVisibleModels.
    NSMutableSet<TMLazyItemModel *> *newInScreenVisibleModels = [NSMutableSet setWithCapacity:newVisibleModels.count];
    NSMutableSet<NSString *> *enteredMuiIDs = [NSMutableSet set];
    for (TMLazyItemModel *itemModel in newVisibleModels) {
        if (itemModel.top < maxY && itemModel.bottom > minY) {
            [newInScreenVisibleModels addObject:itemModel];
            if ([_lastInScreenVisibleModels containsObject:itemModel] == NO) {
                [enteredMuiIDs addObject:itemModel.muiID];
            }
        }
    }
    for (UIView *itemView in _visibleItems) {
        if ([enteredMuiIDs containsObject:itemView.muiID]) {
            if ([itemView respondsToSelector:@selector(mui_didEnterWithTimes:)]) {
                NSInteger times = [_enterTimesDict tm_integerForKey:itemView.muiID];
                times++;
                [_enterTimesDict tm_safeSetObject:@(times) forKey:itemView.muiID];
                [(UIView<TMLazyItemViewProtocol> *)itemView mui_didEnterWithTimes:times];
            }
        }
    }
    _lastInScreenVisibleModels = newInScreenVisibleModels;
}

// Do Binary search here to find index in view model array.
- (NSUInteger)binarySearchForIndex:(NSArray *)frameArray baseLine:(CGFloat)baseLine isFromTop:(BOOL)fromTop
{
    NSInteger min = 0;
    NSInteger max = frameArray.count - 1;
    NSInteger mid = ceilf((min + max) * 0.5f);
    while (mid > min && mid < max) {
        CGRect rect = [(TMLazyItemModel *)[frameArray tm_safeObjectAtIndex:mid] absRect];
        // For top
        if(fromTop) {
            CGFloat itemTop = CGRectGetMinY(rect);
            if (itemTop <= baseLine) {
                CGRect nextItemRect = [(TMLazyItemModel *)[frameArray tm_safeObjectAtIndex:mid + 1] absRect];
                CGFloat nextTop = CGRectGetMinY(nextItemRect);
                if (nextTop > baseLine) {
                    break;
                }
                min = mid;
            } else {
                max = mid;
            }
        }
        // For bottom
        else {
            CGFloat itemBottom = CGRectGetMaxY(rect);
            if (itemBottom >= baseLine) {
                CGRect nextItemRect = [(TMLazyItemModel *)[frameArray tm_safeObjectAtIndex:mid + 1] absRect];
                CGFloat nextBottom = CGRectGetMaxY(nextItemRect);
                if (nextBottom < baseLine) {
                    break;
                }
                min = mid;
            } else {
                max = mid;
            }
        }
        mid = ceilf((CGFloat)(min + max) / 2.f);
    }
    return mid;
}

// Get which views should be shown in LazyScrollView.
// The kind of values In NSSet is muiID.
- (NSSet<TMLazyItemModel *> *)showingItemIndexSetFrom:(CGFloat)startY to:(CGFloat)endY
{
    NSUInteger endBottomIndex = [self binarySearchForIndex:_modelsSortedByBottom baseLine:startY isFromTop:NO];
    [_firstSet removeAllObjects];
    for (NSUInteger i = 0; i <= endBottomIndex; i++) {
        TMLazyItemModel *model = [_modelsSortedByBottom tm_safeObjectAtIndex:i];
        if (model != nil) {
            [_firstSet addObject:model];
        }
    }
    
    NSUInteger endTopIndex = [self binarySearchForIndex:_modelsSortedByTop baseLine:endY isFromTop:YES];
    [_secondSet removeAllObjects];
    for (NSInteger i = 0; i <= endTopIndex; i++) {
        TMLazyItemModel *model = [_modelsSortedByTop tm_safeObjectAtIndex:i];
        if (model != nil) {
            [_secondSet addObject:model];
        }
    }
    
    [_firstSet intersectSet:_secondSet];
    return [_firstSet copy];
}

// Get view models from delegate. Create to indexes for sorting.
- (void)creatScrollViewIndex
{
    NSUInteger count = 0;
    if (self.dataSource) {
        count = [self.dataSource numberOfItemsInScrollView:self];
    }
    
    [_itemModels removeAllObjects];
    for (NSUInteger i = 0 ; i < count ; i++) {
        TMLazyItemModel *rectmodel = nil;
        if (self.dataSource) {
            rectmodel = [self.dataSource scrollView:self itemModelAtIndex:i];
            if (rectmodel.muiID.length == 0) {
                rectmodel.muiID = [NSString stringWithFormat:@"%lu", (unsigned long)i];
            }
        }
        [_itemModels tm_safeAddObject:rectmodel];
    }
    
    _modelsSortedByTop = [_itemModels sortedArrayUsingComparator:^NSComparisonResult(id obj1 ,id obj2) {
        CGRect rect1 = [(TMLazyItemModel *) obj1 absRect];
        CGRect rect2 = [(TMLazyItemModel *) obj2 absRect];
        if (rect1.origin.y < rect2.origin.y) {
            return NSOrderedAscending;
        }  else if (rect1.origin.y > rect2.origin.y) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    _modelsSortedByBottom = [_itemModels sortedArrayUsingComparator:^NSComparisonResult(id obj1 ,id obj2) {
        CGRect rect1 = [(TMLazyItemModel *) obj1 absRect];
        CGRect rect2 = [(TMLazyItemModel *) obj2 absRect];
        CGFloat bottom1 = CGRectGetMaxY(rect1);
        CGFloat bottom2 = CGRectGetMaxY(rect2);
        if (bottom1 > bottom2) {
            return NSOrderedAscending;
        } else if (bottom1 < bottom2) {
            return  NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

#pragma mark Reload

- (void)reloadData
{
    [self creatScrollViewIndex];
    [self assembleSubviews:YES];
}

- (UIView *)dequeueReusableItemWithIdentifier:(NSString *)identifier
{
    return [self dequeueReusableItemWithIdentifier:identifier muiID:nil];
}

- (UIView *)dequeueReusableItemWithIdentifier:(NSString *)identifier muiID:(NSString *)muiID
{
    UIView *result = nil;
    if (identifier && identifier.length > 0) {
        if (_currentReloadingMuiID) {
            for (UIView *item in _visibleItems) {
                if ([item.muiID isEqualToString:_currentReloadingMuiID]
                 && [item.reuseIdentifier isEqualToString:identifier]) {
                    result = item;
                    break;
                }
            }
        }
        if (result == nil) {
            result = [self.reusePool dequeueItemViewForReuseIdentifier:identifier andMuiID:muiID];
        }
        if (result) {
            if (self.autoClearGestures) {
                result.gestureRecognizers = nil;
            }
            if ([result respondsToSelector:@selector(mui_prepareForReuse)]) {
                [(id<TMLazyItemViewProtocol>)result mui_prepareForReuse];
            }
        }
    }
    return result;
}

#pragma mark Clear & Reset

- (void)clearVisibleItems
{
    for (UIView *itemView in _visibleItems) {
        if (itemView.reuseIdentifier.length > 0) {
            itemView.hidden = YES;
            [self.reusePool addItemView:itemView forReuseIdentifier:itemView.reuseIdentifier];
        }
    }
    [_visibleItems removeAllObjects];
}

- (void)removeAllLayouts
{
    [self clearVisibleItems];
}

- (void)resetItemsEnterTimes
{
    [_enterTimesDict removeAllObjects];
    _lastInScreenVisibleModels = [NSSet set];
}

- (void)resetViewEnterTimes
{
    [self resetItemsEnterTimes];
}

#pragma mark Private

- (BOOL)isMuiIdVisible:(NSString *)muiID
{
    for (UIView *itemView in _visibleItems) {
        if ([itemView.muiID isEqualToString:muiID]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isDataSourceValid:(id<TMLazyScrollViewDataSource>)dataSource
{
    return dataSource
        && [dataSource respondsToSelector:@selector(numberOfItemsInScrollView:)]
        && [dataSource respondsToSelector:@selector(scrollView:itemModelAtIndex:)]
        && [dataSource respondsToSelector:@selector(scrollView:itemByMuiID:)];
}

@end

//****************************************************************

@implementation TMLazyOuterScrollViewObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == LazyObserverContext && [keyPath isEqualToString:@"contentOffset"] && _lazyScrollView) {
        [_lazyScrollView outerScrollViewDidScroll];
    }
}

@end
