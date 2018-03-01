//
//  ViewController.m
//  LazyScrollViewDemo
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "ViewController.h"
#import <LazyScroll/TMLazyScrollView.h>


@interface LazyScrollViewCustomView : UILabel <TMLazyItemViewProtocol>

@property (nonatomic, assign) NSUInteger reuseTimes;

@end

@implementation LazyScrollViewCustomView

- (void)mui_prepareForReuse
{
    self.reuseTimes++;
}

@end


@interface ViewController () <TMLazyScrollViewDataSource> {
    NSMutableArray * rectArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // STEP 1 . Create LazyScrollView
    TMLazyScrollView *scrollview = [[TMLazyScrollView alloc] init];
    scrollview.frame = self.view.bounds;
    scrollview.dataSource = self;
    scrollview.autoAddSubview = YES;
    [self.view addSubview:scrollview];
    
    // Here is frame array for test.
    // LazyScrollView must know every rect before rending.
    rectArray = [[NSMutableArray alloc] init];
    CGFloat maxY = 0, currentY = 10;
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    // Create a single column layout with 5 elements;
    for (int i = 0; i < 5; i++) {
        [self addRect:CGRectMake(10, i * 80 + currentY, viewWidth - 20, 80 - 3) andUpdateMaxY:&maxY];
    }
    // Create a double column layout with 10 elements;
    currentY = maxY + 10;
    for (int i = 0; i < 10; i++) {
        [self addRect:CGRectMake((i % 2) * (viewWidth - 20 + 3) / 2 + 10, i / 2 * 80 + currentY, (viewWidth - 20 - 3) / 2, 80 - 3) andUpdateMaxY:&maxY];
    }
    // Create a trible column layout with 15 elements;
    currentY = maxY + 10;
    for (int i = 0; i < 15; i++) {
        [self addRect:CGRectMake((i % 3) * (viewWidth - 20 + 6) / 3 + 10, i / 3 * 80 + currentY, (viewWidth - 20 - 6) / 3, 80 - 3) andUpdateMaxY:&maxY];
    }
    
    // STEP 3 reload LazyScrollView
    scrollview.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), maxY + 10);
    [scrollview reloadData];
}

// STEP 2 implement datasource delegate.
- (NSUInteger)numberOfItemInScrollView:(TMLazyScrollView *)scrollView
{
    return rectArray.count;
}

- (TMLazyRectModel *)scrollView:(TMLazyScrollView *)scrollView rectModelAtIndex:(NSUInteger)index
{
    CGRect rect = [(NSValue *)[rectArray objectAtIndex:index] CGRectValue];
    TMLazyRectModel *rectModel = [[TMLazyRectModel alloc] init];
    rectModel.absRect = rect;
    rectModel.muiID = [NSString stringWithFormat:@"%zd", index];
    return rectModel;
}

- (UIView *)scrollView:(TMLazyScrollView *)scrollView itemByMuiID:(NSString *)muiID
{
    // Find view that is reuseable first.
    LazyScrollViewCustomView *label = (LazyScrollViewCustomView *)[scrollView dequeueReusableItemWithIdentifier:@"testView"];
    NSInteger index = [muiID integerValue];
    if (!label) {
        NSLog(@"create a new label");
        label = [LazyScrollViewCustomView new];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.reuseIdentifier = @"testView";
        label.backgroundColor = [self randomColor];
    }
    label.frame = [(NSValue *)[rectArray objectAtIndex:index] CGRectValue];
    if (label.reuseTimes > 0) {
        label.text = [NSString stringWithFormat:@"%zd\nlast index: %@\nreuse times: %zd", index, label.muiID, label.reuseTimes];
    } else {
        label.text = [NSString stringWithFormat:@"%zd", index];
    }
    return label;
}

#pragma mark - Private

- (void)addRect:(CGRect)newRect andUpdateMaxY:(CGFloat *)maxY
{
    if (CGRectGetMaxY(newRect) > *maxY) {
        *maxY = CGRectGetMaxY(newRect);
    }
    [rectArray addObject:[NSValue valueWithCGRect:newRect]];
}

- (UIColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); // 0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end
