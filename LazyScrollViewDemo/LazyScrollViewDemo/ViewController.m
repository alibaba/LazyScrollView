//
//  ViewController.m
//  LazyScrollViewDemo
//
//  Copyright (c) 2017 Alibaba. All rights reserved.
//

#import "ViewController.h"
#import <LazyScroll/TMMuiLazyScrollView.h>


@interface LazyScrollViewCustomView : UILabel <TMMuiLazyScrollViewCellProtocol>

@end

@implementation LazyScrollViewCustomView

- (void)mui_prepareForReuse
{
    NSLog(@"%@ - Prepare For Reuse", self.text);
}

- (void)mui_didEnterWithTimes:(NSUInteger)times
{
    NSLog(@"%@ - Did Enter With Times - %zd", self.text, times);
}

- (void)mui_afterGetView
{
    NSLog(@"%@ - AfterGetView", self.text);
}

@end


@interface ViewController () <TMMuiLazyScrollViewDataSource> {
    NSMutableArray * rectArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // STEP 1 . Create LazyScrollView
    TMMuiLazyScrollView *scrollview = [[TMMuiLazyScrollView alloc] init];
    scrollview.frame = self.view.bounds;
    scrollview.dataSource = self;
    [self.view addSubview:scrollview];
    
    // Here is frame array for test.
    // LazyScrollView must know every rect before rending.
    rectArray = [[NSMutableArray alloc] init];
    
    // Create a single column layout with 5 elements;
    for (int i = 0; i < 5; i++) {
        [rectArray addObject:[NSValue valueWithCGRect:CGRectMake(10, i * 80 + 2 , self.view.bounds.size.width - 20, 80 - 2)]];
    }
    // Create a double column layout with 10 elements;
    for (int i = 0; i < 10; i++) {
        [rectArray addObject:[NSValue valueWithCGRect:CGRectMake((i % 2) * self.view.bounds.size.width / 2 + 3, 410 + i / 2 * 80 + 2 , self.view.bounds.size.width / 2 - 3, 80 - 2)]];
    }
    // Create a trible column layout with 15 elements;
    for (int i = 0; i < 15; i++) {
        [rectArray addObject:[NSValue valueWithCGRect:CGRectMake((i % 3) * self.view.bounds.size.width / 3 + 1, 820 + i / 3 * 80 + 2 , self.view.bounds.size.width / 3 - 3, 80 - 2)]];
    }
    scrollview.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 1230);
    
    // STEP 3 reload LazyScrollView
    [scrollview reloadData];
}

// STEP 2 implement datasource delegate.
- (NSUInteger)numberOfItemInScrollView:(TMMuiLazyScrollView *)scrollView
{
    return rectArray.count;
}

- (TMMuiRectModel *)scrollView:(TMMuiLazyScrollView *)scrollView rectModelAtIndex:(NSUInteger)index
{
    CGRect rect = [(NSValue *)[rectArray objectAtIndex:index] CGRectValue];
    TMMuiRectModel *rectModel = [[TMMuiRectModel alloc] init];
    rectModel.absRect = rect;
    rectModel.muiID = [NSString stringWithFormat:@"%zd", index];
    return rectModel;
}

- (UIView *)scrollView:(TMMuiLazyScrollView *)scrollView itemByMuiID:(NSString *)muiID
{
    // Find view that is reuseable first.
    LazyScrollViewCustomView *label = (LazyScrollViewCustomView *)[scrollView dequeueReusableItemWithIdentifier:@"testView"];
    NSInteger index = [muiID integerValue];
    if (!label) {
        label = [[LazyScrollViewCustomView alloc]initWithFrame:[(NSValue *)[rectArray objectAtIndex:index] CGRectValue]];
        label.textAlignment = NSTextAlignmentCenter;
        label.reuseIdentifier = @"testView";
    }
    label.frame = [(NSValue *)[rectArray objectAtIndex:index] CGRectValue];
    label.text = [NSString stringWithFormat:@"%zd", index];
    label.backgroundColor = [self randomColor];
    [scrollView addSubview:label];
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)]];
    return label;
}

#pragma mark - Private

- (UIColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); // 0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)click:(UIGestureRecognizer *)recognizer
{
    LazyScrollViewCustomView *label = (LazyScrollViewCustomView *)recognizer.view;
    NSLog(@"Click - %@", label.muiID);
}

@end
