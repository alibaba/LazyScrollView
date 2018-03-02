//
//  OuterViewController.m
//  LazyScrollViewDemo
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "OuterViewController.h"
#import <LazyScroll/LazyScroll.h>
#import <TMUtils/TMUtils.h>

@interface OuterViewController () <TMLazyScrollViewDataSource> {
    NSMutableArray * _rectArray;
    NSMutableArray * _colorArray;
    TMLazyScrollView * _scrollView;
}

@end

@implementation OuterViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"Outer";
    }
    return self;
}

- (void)dealloc
{
    // VERY IMPORTANT!
    _scrollView.outerScrollView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollView = [[TMLazyScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.dataSource = self;
    _scrollView.autoAddSubview = YES;
    
    _rectArray = [[NSMutableArray alloc] init];
    CGFloat maxY = 0;
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    for (int i = 0; i < 20; i++) {
        [self addRect:CGRectMake((i % 2) * (viewWidth - 20 + 3) / 2 + 10, i / 2 * 80 + 10, (viewWidth - 20 - 3) / 2, 80 - 3) andUpdateMaxY:&maxY];
    }
    
    _colorArray = [NSMutableArray arrayWithCapacity:_rectArray.count];
    CGFloat hue = 0;
    for (int i = 0; i < _rectArray.count; i++) {
        [_colorArray addObject:[UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1]];
        hue += 0.05;
        if (hue >= 1) {
            hue = 0;
        }
    }
    
    _scrollView.contentSize = CGSizeMake(viewWidth, maxY + 10);
    _scrollView.frame = CGRectMake(0, 0, viewWidth, maxY + 10);
    _scrollView.outerScrollView = self.tableView;
    self.tableView.tableFooterView = _scrollView;
    [_scrollView reloadData];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"The table view's footer view is a LazyScrollView.";
    } else {
        cell.textLabel.text = [@(indexPath.row) stringValue];
    }
    return cell;
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
        view.backgroundColor = [_colorArray tm_safeObjectAtIndex:index];
    }
    view.frame = [(NSValue *)[_rectArray objectAtIndex:index] CGRectValue];
    return view;
}

#pragma mark Private

- (void)addRect:(CGRect)newRect andUpdateMaxY:(CGFloat *)maxY
{
    if (CGRectGetMaxY(newRect) > *maxY) {
        *maxY = CGRectGetMaxY(newRect);
    }
    [_rectArray addObject:[NSValue valueWithCGRect:newRect]];
}

@end
