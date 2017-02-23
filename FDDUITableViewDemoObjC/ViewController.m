//
//  ViewController.m
//  FDDUITableViewDemoObjC
//
//  Created by denglibing on 2017/2/14.
//  Copyright © 2017年 denglibing. All rights reserved.
//

#import "ViewController.h"
#import "ViewController2.h"

#import "FDDTableViewConverter.h"

#import "HDTableViewCell.h"

#import "FDDBaseCellModel.h"

@interface ViewController ()

@property (nonatomic, strong) FDDTableViewConverter *tableViewConverter;

@end

@implementation ViewController

- (void)dealloc{
    NSLog(@"%@ dealloc", NSStringFromClass(self.class));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ViewController";
    
    [self disposeDataSources];
    [self disposeTableViewConverter];
}

- (void)disposeDataSources{
    NSArray *randomSources = @[@"Swift is now open source!",
                               @"We are excited by this new chapter in the story of Swift. After Apple unveiled the Swift programming language, it quickly became one of the fastest growing languages in history. Swift makes it easy to write software that is incredibly fast and safe by design. Now that Swift is open source, you can help make the best general purpose programming language available everywhere",
                               @"For students, learning Swift has been a great introduction to modern programming concepts and best practices. And because it is now open, their Swift skills will be able to be applied to an even broader range of platforms, from mobile devices to the desktop to the cloud.",
                               @"Welcome to the Swift community. Together we are working to build a better programming language for everyone.",
                               @"– The Swift Team"];
    for (int i=0; i<30; i++) {
        NSInteger randomIndex = arc4random() % 5;
        FDDBaseCellModel *cellModel = [FDDBaseCellModel modelFromCellClass:HDTableViewCell.class cellHeight:[HDTableViewCell cellHeightWithCellData:randomSources[randomIndex]] cellData:randomSources[randomIndex]];
        [self.dataArr addObject:cellModel];
    }
}


- (void)disposeTableViewConverter{
    _tableViewConverter = [[FDDTableViewConverter alloc] initWithTableViewCarrier:self daraSources:self.dataArr];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = _tableViewConverter;
    tableView.dataSource = _tableViewConverter;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    __weak typeof(self) weakSelf = self;
    [_tableViewConverter registerTableViewMethod:@selector(tableView:didSelectRowAtIndexPath:) handleParams:^id(NSArray *params) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.navigationController pushViewController:[ViewController2 new] animated:YES];
        return nil;
    }];
    
    [_tableViewConverter registerTableViewMethod:@selector(tableView:titleForHeaderInSection:) handleParams:^id(NSArray *params) {
        return @"";
    }];
    
    [_tableViewConverter registerTableViewMethod:@selector(tableView:cellForRowAtIndexPath:) handleParams:^id(NSArray *params) {
        UITableView *tableView = params[0];
        NSIndexPath *indexPath = params[1];
        FDDBaseCellModel *cellModel = weakSelf.dataArr[indexPath.row];
        FDDBaseTableViewCell *cell = [tableView cellForIndexPath:indexPath cellClass:cellModel.cellClass];
        [cell setCellData:cellModel.cellData delegate:weakSelf];
        [cell setSeperatorLine:indexPath numberOfRowsInSection:weakSelf.dataArr.count];
        return cell;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
