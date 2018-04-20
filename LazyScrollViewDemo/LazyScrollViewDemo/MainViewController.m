//
//  MainViewController.m
//  LazyScrollViewDemo
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "MainViewController.h"
#import "OuterViewController.h"
#import "MoreViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) NSArray <NSString *> *demoArray;

@end

@implementation MainViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"LazyScrollDemo";
        self.demoArray = @[@"Reuse", @"OuterScrollView", @"LoadMore", @"Async"];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.demoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.demoArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *demoName = self.demoArray[indexPath.row];
    UIViewController *vc;
    if ([demoName isEqualToString:@"OuterScrollView"]) {
        vc = [OuterViewController new];
    } else if ([demoName isEqualToString:@"LoadMore"]) {
        vc = [MoreViewController new];
    } else {
        Class demoVcClass = NSClassFromString([demoName stringByAppendingString:@"ViewController"]);
        vc = [demoVcClass new];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

@end
