//
//  ModelBucketTest.m
//  ModelBucketTest
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>
#import <LazyScroll/LazyScroll.h>

@interface ModelBucketTest : XCTestCase

@end

@implementation ModelBucketTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testModelBucket {
    TMLazyModelBucket *bucket= [[TMLazyModelBucket alloc] initWithBucketHeight:20];
    TMLazyItemModel *firstModel = [ModelBucketTest createModelHelperWithY:0 height:10];
    [bucket addModel:firstModel];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:10 height:10]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:20 height:10]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:30 height:10]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:40 height:10]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:50 height:10]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:0 height:20]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:10 height:20]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:20 height:20]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:30 height:20]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:40 height:20]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:0 height:30]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:10 height:30]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:20 height:30]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:30 height:30]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:0 height:40]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:10 height:40]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:20 height:40]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:0 height:50]];
    [bucket addModel:[ModelBucketTest createModelHelperWithY:10 height:50]];
    TMLazyItemModel *lastModel = [ModelBucketTest createModelHelperWithY:0 height:60];
    [bucket addModel:lastModel];
    
    assertThat([bucket showingModelsFrom:0 to:60], hasCountOf(21));
    assertThat([bucket showingModelsFrom:0 to:50], hasCountOf(20));
    assertThat([bucket showingModelsFrom:0 to:40], hasCountOf(18));
    assertThat([bucket showingModelsFrom:0 to:30], hasCountOf(15));
    NSSet *set = [bucket showingModelsFrom:0 to:20];
    assertThat(set, hasCountOf(11));
    set = [set valueForKey:@"muiID"];
    assertThat(set, containsInAnyOrder(@"10", @"20", @"30", @"40", @"50", @"60", @"1010", @"1020", @"1030", @"1040", @"1050", nil));
    set = [bucket showingModelsFrom:0 to:10];
    assertThat(set, hasCountOf(6));
    set = [set valueForKey:@"muiID"];
    assertThat(set, containsInAnyOrder(@"10", @"20", @"30", @"40", @"50", @"60", nil));
    
    [bucket removeModel:lastModel];

    assertThat([bucket showingModelsFrom:0 to:60], hasCountOf(20));
    assertThat([bucket showingModelsFrom:0 to:50], hasCountOf(19));
    assertThat([bucket showingModelsFrom:0 to:40], hasCountOf(17));
    assertThat([bucket showingModelsFrom:0 to:30], hasCountOf(14));
    set = [bucket showingModelsFrom:0 to:20];
    assertThat(set, hasCountOf(10));
    set = [set valueForKey:@"muiID"];
    assertThat(set, containsInAnyOrder(@"10", @"20", @"30", @"40", @"50", @"1010", @"1020", @"1030", @"1040", @"1050", nil));
    set = [bucket showingModelsFrom:0 to:10];
    assertThat(set, hasCountOf(5));
    set = [set valueForKey:@"muiID"];
    assertThat(set, containsInAnyOrder(@"10", @"20", @"30", @"40", @"50", nil));
    
    firstModel.absRect = CGRectMake(0, 30, 10, 30);
    [bucket reloadModel:firstModel];
    
    assertThat([bucket showingModelsFrom:0 to:60], hasCountOf(20));
    assertThat([bucket showingModelsFrom:0 to:50], hasCountOf(19));
    assertThat([bucket showingModelsFrom:0 to:40], hasCountOf(17));
    assertThat([bucket showingModelsFrom:0 to:30], hasCountOf(13));
    set = [bucket showingModelsFrom:0 to:20];
    assertThat(set, hasCountOf(9));
    set = [set valueForKey:@"muiID"];
    assertThat(set, containsInAnyOrder(@"20", @"30", @"40", @"50", @"1010", @"1020", @"1030", @"1040", @"1050", nil));
    set = [bucket showingModelsFrom:0 to:10];
    assertThat(set, hasCountOf(4));
    set = [set valueForKey:@"muiID"];
    assertThat(set, containsInAnyOrder(@"20", @"30", @"40", @"50", nil));
    set = [bucket showingModelsFrom:30 to:60];
    assertThat(set, hasCountOf(15));
    set = [set valueForKey:@"muiID"];
    assertThat(set, containsInAnyOrder(@"10", @"40", @"50", @"1030", @"1040", @"1050", @"2020", @"2030", @"2040", @"3010", @"3020", @"3030", @"4010", @"4020", @"5010", nil));
    set = [bucket showingModelsFrom:30 to:50];
    assertThat(set, hasCountOf(14));
    set = [set valueForKey:@"muiID"];
    assertThat(set, containsInAnyOrder(@"10", @"40", @"50", @"1030", @"1040", @"1050", @"2020", @"2030", @"2040", @"3010", @"3020", @"3030", @"4010", @"4020", nil));
    
    [bucket clear];
    assertThat([bucket showingModelsFrom:0 to:50], hasCountOf(0));
    assertThat([bucket showingModelsFrom:0 to:40], hasCountOf(0));
    assertThat([bucket showingModelsFrom:0 to:30], hasCountOf(0));
    assertThat([bucket showingModelsFrom:0 to:20], hasCountOf(0));
    assertThat([bucket showingModelsFrom:0 to:10], hasCountOf(0));
}

+ (TMLazyItemModel *)createModelHelperWithY:(CGFloat)y height:(CGFloat)height
{
    TMLazyItemModel *model = [TMLazyItemModel new];
    model.absRect = CGRectMake(0, y, 10, height);
    model.muiID = [NSString stringWithFormat:@"%.0f", y * 100 + height];
    return model;
}

@end
