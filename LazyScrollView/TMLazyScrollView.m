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

#define LazyBufferHeight 30.0
#define LazyHalfBufferHeight 15.0
void * const LazyObserverContext = "LazyObserverContext";

@interface TMLazyOuterScrollViewObserver: NSObject

@property (nonatomic, weak) TMLazyScrollView *lazyScrollView;

@end

//****************************************************************

@interface TMLazyScrollView () {
    NSMutableSet<UIView *> *_visibleItems;
    NSMutableSet<UIView *> *_inScreenVisibleItems;
    
    // Store item models.
    NSMutableArray<TMLazyItemModel *> *_itemsModels;
    
    // Store view models below contentOffset of ScrollView
    NSMutableSet<NSString *> *_firstSet;
    // Store view models above contentOffset + height of ScrollView
    NSMutableSet<NSString *> *_secondSet;
    
    // View Model sorted by Top Edge.
    NSArray<TMLazyItemModel *> *_modelsSortedByTop;
    // View Model sorted by Bottom Edge.
    NSArray<TMLazyItemModel *> *_modelsSortedByBottom;
    
    // It is used to store views need to assign new value after reload.
    NSMutableSet<NSString *> *_shouldReloadItems;
    
    // Store the times of view entered the screen, the key is muiID.
    NSMutableDictionary<NSString *, NSNumber *> *_enterDic;
    
    // Record current muiID of visible view for calculate.
    // Will be used for dequeueReusableItem methods.
    NSString *_currentVisibleItemMuiID;
    
    // Record muiIDs of visible items. Used for calc enter times.
    NSSet<NSString *> *_muiIDOfVisibleViews;
    // Store last time visible muiID. Used for calc enter times.
    NSSet<NSString *> *_lastVisibleMuiID;
    
    BOOL _forwardingDelegateCanPerformScrollViewDidScrollSelector;
    
    @package
    // Record contentOffset of scrollview in previous time that calculate
    // views to show
    CGPoint _lastScrollOffset;
}

@property (nonatomic, strong) TMLazyOuterScrollViewObserver *outerScrollViewObserver;

- (void)outerScrollViewDidScroll;

@end

@implementation TMLazyScrollView

#pragma mark Getter & Setter

- (NSSet *)inScreenVisibleItems
{
    return [_inScreenVisibleItems copy];
}

- (NSSet *)visibleItems
{
    return [_visibleItems copy];
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
        self.autoresizesSubviews = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        _shouldReloadItems = [[NSMutableSet alloc] init];
        
        _modelsSortedByTop = [[NSArray alloc] init];
        _modelsSortedByBottom = [[NSArray alloc]init];
        
        _reusePool = [TMLazyReusePool new];
        
        _visibleItems = [[NSMutableSet alloc] init];
        _inScreenVisibleItems = [[NSMutableSet alloc] init];
        
        _itemsModels = [[NSMutableArray alloc] init];
        
        _firstSet = [[NSMutableSet alloc] initWithCapacity:30];
        _secondSet = [[NSMutableSet alloc] initWithCapacity:30];
        
        _enterDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    _dataSource = nil;
    self.delegate = nil;
    self.outerScrollView = nil;
}

#pragma mark ScrollEvent

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    // Calculate which item views should be shown.
    // Calculating will cost some time, so here is a buffer for reducing
    // times of calculating.
    CGFloat currentY = contentOffset.y;
    CGFloat buffer = LazyHalfBufferHeight;
    if (buffer < ABS(currentY - _lastScrollOffset.y)) {
        _lastScrollOffset = self.contentOffset;
        [self assembleSubviews];
        [self findViewsInVisibleRect];
    }
}

- (void)outerScrollViewDidScroll
{
    CGFloat currentY = _outerScrollView.contentOffset.y;
    CGFloat buffer = LazyHalfBufferHeight;
    if (buffer < ABS(currentY - _lastScrollOffset.y)) {
        _lastScrollOffset = _outerScrollView.contentOffset;
        [self assembleSubviews];
        [self findViewsInVisibleRect];
    }
}

#pragma mark Core Logic

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
- (NSSet<NSString *> *)showingItemIndexSetFrom:(CGFloat)startY to:(CGFloat)endY
{
    NSUInteger endBottomIndex = [self binarySearchForIndex:_modelsSortedByBottom baseLine:startY isFromTop:NO];
    [_firstSet removeAllObjects];
    for (NSUInteger i = 0; i <= endBottomIndex; i++) {
        TMLazyItemModel *model = [_modelsSortedByBottom tm_safeObjectAtIndex:i];
        if (model != nil) {
            [_firstSet addObject:model.muiID];
        }
    }
    
    NSUInteger endTopIndex = [self binarySearchForIndex:_modelsSortedByTop baseLine:endY isFromTop:YES];
    [_secondSet removeAllObjects];
    for (NSInteger i = 0; i <= endTopIndex; i++) {
        TMLazyItemModel *model = [_modelsSortedByTop tm_safeObjectAtIndex:i];
        if (model != nil) {
            [_secondSet addObject:model.muiID];
        }
    }
    
    [_firstSet intersectSet:_secondSet];
    return [_firstSet copy];
}

// Get view models from delegate. Create to indexes for sorting.
- (void)creatScrollViewIndex
{
    NSUInteger count = 0;
    if (_dataSource &&
        [_dataSource conformsToProtocol:@protocol(TMLazyScrollViewDataSource)] &&
        [_dataSource respondsToSelector:@selector(numberOfItemsInScrollView:)]) {
        count = [_dataSource numberOfItemsInScrollView:self];
    }
    
    [_itemsModels removeAllObjects];
    for (NSUInteger i = 0 ; i < count ; i++) {
        TMLazyItemModel *rectmodel = nil;
        if (_dataSource &&
            [_dataSource conformsToProtocol:@protocol(TMLazyScrollViewDataSource)] &&
            [_dataSource respondsToSelector:@selector(scrollView:itemModelAtIndex:)]) {
            rectmodel = [_dataSource scrollView:self itemModelAtIndex:i];
            if (rectmodel.muiID.length == 0) {
                rectmodel.muiID = [NSString stringWithFormat:@"%lu", (unsigned long)i];
            }
        }
        [_itemsModels tm_safeAddObject:rectmodel];
    }
    
    _modelsSortedByTop = [_itemsModels sortedArrayUsingComparator:^NSComparisonResult(id obj1 ,id obj2) {
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
    
    _modelsSortedByBottom = [_itemsModels sortedArrayUsingComparator:^NSComparisonResult(id obj1 ,id obj2) {
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

- (void)findViewsInVisibleRect
{
    NSMutableSet *itemViewSet = [_muiIDOfVisibleViews mutableCopy];
    [itemViewSet minusSet:_lastVisibleMuiID];
    for (UIView *view in _visibleItems) {
        if (view && [itemViewSet containsObject:view.muiID]) {
            if ([view conformsToProtocol:@protocol(TMLazyItemViewProtocol)] &&
                [view respondsToSelector:@selector(mui_didEnterWithTimes:)]) {
                NSUInteger times = 0;
                if ([_enterDic tm_safeObjectForKey:view.muiID] != nil) {
                    times = [_enterDic tm_integerForKey:view.muiID] + 1;
                }
                NSNumber *showTimes = [NSNumber numberWithUnsignedInteger:times];
                [_enterDic tm_safeSetObject:showTimes forKey:view.muiID];
                [(UIView<TMLazyItemViewProtocol> *)view mui_didEnterWithTimes:times];
            }
        }
    }
    _lastVisibleMuiID = [_muiIDOfVisibleViews copy];
}

// A simple method to show view that should be shown in LazyScrollView.
- (void)assembleSubviews
{
    if (_outerScrollView) {
        CGPoint pointInScrollView = [self.superview convertPoint:self.frame.origin toView:_outerScrollView];
        CGFloat minY = _outerScrollView.contentOffset.y  - pointInScrollView.y - LazyHalfBufferHeight;
        //maxY 计算的逻辑，需要修改，增加的height，需要计算的更加明确
        CGFloat maxY = _outerScrollView.contentOffset.y + _outerScrollView.frame.size.height - pointInScrollView.y + LazyHalfBufferHeight;
        if (maxY > 0) {
            [self assembleSubviewsForReload:NO minY:minY maxY:maxY];
        }
        
    }
    else
    {
        CGRect visibleBounds = self.bounds;
        CGFloat minY = CGRectGetMinY(visibleBounds) - LazyBufferHeight;
        CGFloat maxY = CGRectGetMaxY(visibleBounds) + LazyBufferHeight;
        [self assembleSubviewsForReload:NO minY:minY maxY:maxY];
    }
}

- (void)assembleSubviewsForReload:(BOOL)isReload minY:(CGFloat)minY maxY:(CGFloat)maxY
{
    NSSet<NSString *> *itemShouldShowSet = [self showingItemIndexSetFrom:minY to:maxY];
    if (_outerScrollView) {
        _muiIDOfVisibleViews = [self showingItemIndexSetFrom:minY to:maxY];
    }
    else{
        _muiIDOfVisibleViews = [self showingItemIndexSetFrom:CGRectGetMinY(self.bounds) to:CGRectGetMaxY(self.bounds)];
    }
    NSMutableSet<UIView *> *recycledItems = [[NSMutableSet alloc] init];
    // For recycling. Find which views should not in visible area.
    NSSet *visibles = [_visibleItems copy];
    for (UIView *view in visibles) {
        // Make sure whether the view should be shown.
        BOOL isToShow  = [itemShouldShowSet containsObject:view.muiID];
        if (!isToShow) {
            if ([view respondsToSelector:@selector(mui_didLeave)]){
                [(UIView<TMLazyItemViewProtocol> *)view mui_didLeave];
            }
            // If this view should be recycled and the length of its reuseidentifier is over 0.
            if (view.reuseIdentifier.length > 0) {
                // Then recycle the view.
                [self.reusePool addItemView:view forReuseIdentifier:view.reuseIdentifier];
                view.hidden = YES;
                [recycledItems addObject:view];
            } else if(isReload && view.muiID) {
                // Need to reload unreusable views.
                [_shouldReloadItems addObject:view.muiID];
            }
        } else if (isReload && view.muiID) {
            [_shouldReloadItems addObject:view.muiID];
        }
        
    }
    [_visibleItems minusSet:recycledItems];
    [recycledItems removeAllObjects];
    // Creare new view.
    for (NSString *muiID in itemShouldShowSet) {
        BOOL shouldReload = isReload || [_shouldReloadItems containsObject:muiID];
        if (![self isCellVisible:muiID] || [_shouldReloadItems containsObject:muiID]) {
            if (_dataSource &&
                [_dataSource conformsToProtocol:@protocol(TMLazyScrollViewDataSource)] &&
                [_dataSource respondsToSelector:@selector(scrollView:itemByMuiID:)]) {
                // Create view by dataSource.
                // If you call dequeue method in your dataSource, the currentVisibleItemMuiID
                // will be used for searching reusable view.
                if (shouldReload) {
                    _currentVisibleItemMuiID = muiID;
                }
                UIView *viewToShow = [_dataSource scrollView:self itemByMuiID:muiID];
                _currentVisibleItemMuiID = nil;
                // Call afterGetView.
                if ([viewToShow conformsToProtocol:@protocol(TMLazyItemViewProtocol)] &&
                    [viewToShow respondsToSelector:@selector(mui_afterGetView)]) {
                    [(UIView<TMLazyItemViewProtocol> *)viewToShow mui_afterGetView];
                }
                if (viewToShow) {
                    viewToShow.muiID = muiID;
                    viewToShow.hidden = NO;
                    if (![_visibleItems containsObject:viewToShow]) {
                        [_visibleItems addObject:viewToShow];
                    }
                    if (_autoAddSubview) {
                        if (viewToShow.superview != self) {
                            [self addSubview:viewToShow];
                        }
                    }
                }
            }
            [_shouldReloadItems removeObject:muiID];
        }
    }
    [_inScreenVisibleItems removeAllObjects];
    for (UIView *view in _visibleItems) {
        if ([view isKindOfClass:[UIView class]] && view.superview) {
            CGRect absRect = [view.superview convertRect:view.frame toView:self];
            if ((absRect.origin.y + absRect.size.height >= CGRectGetMinY(self.bounds)) &&
                (absRect.origin.y <= CGRectGetMaxY(self.bounds))) {
                [_inScreenVisibleItems addObject:view];
            }
        }
    }
}

// Reloads everything and redisplays visible views.
- (void)reloadData
{
    [self creatScrollViewIndex];
    if (_itemsModels.count > 0) {
        if (_outerScrollView) {
            CGRect rectInScrollView = [self convertRect:self.frame toView:_outerScrollView];
            CGFloat minY = _outerScrollView.contentOffset.y - rectInScrollView.origin.y - LazyBufferHeight;
            CGFloat maxY = _outerScrollView.contentOffset.y + _outerScrollView.frame.size.height - rectInScrollView.origin.y + _outerScrollView.frame.size.height + LazyBufferHeight;
            if (maxY > 0) {
                [self assembleSubviewsForReload:YES minY:minY maxY:maxY];
            }
        }
        else{
            CGRect visibleBounds = self.bounds;
            // 上下增加 20point 的缓冲区
            CGFloat minY = CGRectGetMinY(visibleBounds) - LazyBufferHeight;
            CGFloat maxY = CGRectGetMaxY(visibleBounds) + LazyBufferHeight;
            [self assembleSubviewsForReload:YES minY:minY maxY:maxY];
        }
        [self findViewsInVisibleRect];
    }

}

// To acquire an already allocated view that can be reused by reuse identifier.
- (UIView *)dequeueReusableItemWithIdentifier:(NSString *)identifier
{
    return [self dequeueReusableItemWithIdentifier:identifier muiID:nil];
}

// To acquire an already allocated view that can be reused by reuse identifier.
// Use muiID for higher priority.
- (UIView *)dequeueReusableItemWithIdentifier:(NSString *)identifier muiID:(NSString *)muiID
{
    UIView *result = nil;
    if (identifier && identifier.length > 0) {
        if (_currentVisibleItemMuiID) {
            for (UIView *item in _visibleItems) {
                if ([item.muiID isEqualToString:_currentVisibleItemMuiID] && [item.reuseIdentifier isEqualToString:identifier]) {
                    result = item;
                    break;
                }
            }
        }
        if (result == nil && muiID && muiID.length > 0) {
            result = [self.reusePool dequeueItemViewForReuseIdentifier:identifier andMuiID:muiID];
        }
        if (result == nil) {
            result = [self.reusePool dequeueItemViewForReuseIdentifier:identifier];
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

//Make sure whether the view is visible accroding to muiID.
- (BOOL)isCellVisible:(NSString *)muiID
{
    BOOL result = NO;
    NSSet *visibles = [_visibleItems copy];
    for (UIView *view in visibles) {
        if ([view.muiID isEqualToString:muiID]) {
            result = YES;
            break;
        }
    }
    return result;
}

- (void)clearItemsAndReusePool
{
    for (UIView *view in _visibleItems) {
        view.hidden = YES;
    }
    [_visibleItems removeAllObjects];
    [self.reusePool clear];
}

- (void)removeAllLayouts
{
    [self clearItemsAndReusePool];
}

- (void)resetItemsEnterTimes
{
    [_enterDic removeAllObjects];
    _lastVisibleMuiID = nil;
}

- (void)resetViewEnterTimes
{
    [self resetItemsEnterTimes];
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
