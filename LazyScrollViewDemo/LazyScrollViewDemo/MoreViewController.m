//
//  MoreViewController.m
//  LazyScrollViewDemo
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "MoreViewController.h"
#import <LazyScroll/LazyScroll.h>
#import <TMUtils/TMUtils.h>

@interface MoreViewController () <TMLazyScrollViewDataSource> {
    NSMutableArray * _rectArray;
    NSMutableArray * _colorArray;
    TMLazyScrollView * _scrollView;
    
    CGFloat maxY;
}

@end

@implementation MoreViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"More";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollView = [[TMLazyScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.dataSource = self;
    _scrollView.autoAddSubview = YES;
    [self.view addSubview:_scrollView];
    
    _rectArray = [[NSMutableArray alloc] init];
    maxY = 0;
    CGFloat currentY = 10;
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    for (int i = 0; i < 10; i++) {
        [self addRect:CGRectMake(10, i * 80 + currentY, viewWidth - 20, 80 - 3)];
    }
    
    _colorArray = [NSMutableArray arrayWithCapacity:_rectArray.count];
    CGFloat hue = 0;
    for (int i = 0; i < 20; i++) {
        [_colorArray addObject:[UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1]];
        hue += 0.05;
    }
    
    _scrollView.contentSize = CGSizeMake(viewWidth, maxY + 10);
    [_scrollView reloadData];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"LoadMore" style:UIBarButtonItemStylePlain target:self action:@selector(loadMoreAction)];
}

- (void)loadMoreAction
{
    CGFloat currentY = maxY + 3;
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    for (int i = 0; i < 10; i++) {
        [self addRect:CGRectMake(10, i * 80 + currentY, viewWidth - 20, 80 - 3)];
    }
    
    _scrollView.contentSize = CGSizeMake(viewWidth, maxY + 10);
    [_scrollView loadMoreDataFromIndex:_rectArray.count - 10];
}

#pragma mark LazyScrollView

- (NSUInteger)numberOfItemsInScrollView:(TMLazyScrollView *)scrollView
{
    return _rectArray.count;
}

- (TMLazyItemModel *)scrollView:(TMLazyScrollView *)scrollView itemModelAtIndex:(NSUInteger)index
{
    CGRect rect = [(NSValue *)[_rectArray objectAtIndex:index] CGRectValue];
    TMLazyItemModel *rectModel = [[TMLazyItemModel alloc] init];
    rectModel.absRect = rect;
    rectModel.muiID = [NSString stringWithFormat:@"%zd", index];
    return rectModel;
}

- (UIView *)scrollView:(TMLazyScrollView *)scrollView itemByMuiID:(NSString *)muiID
{
    UIView *view = (UIView *)[scrollView dequeueReusableItemWithIdentifier:@"testView"];
    NSInteger index = [muiID integerValue];
    if (!view) {
        NSLog(@"create a new view");
        view = [UIView new];
        view.reuseIdentifier = @"testView";
        view.backgroundColor = [_colorArray tm_safeObjectAtIndex:index % 20];
    }
    view.frame = [(NSValue *)[_rectArray objectAtIndex:index] CGRectValue];
    return view;
}

#pragma mark Private

- (void)addRect:(CGRect)newRect
{
    if (CGRectGetMaxY(newRect) > maxY) {
        maxY = CGRectGetMaxY(newRect);
    }
    [_rectArray addObject:[NSValue valueWithCGRect:newRect]];
}

@end
