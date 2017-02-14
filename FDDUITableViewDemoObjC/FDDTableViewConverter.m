//
//  FDDTableViewConverter.m
//  FDDUITableViewDemoObjC
//
//  Created by denglibing on 2017/2/14.
//  Copyright © 2017年 denglibing. All rights reserved.
//

#import "FDDTableViewConverter.h"

#import "FDDBaseTableViewCell.h"

#import "FDDBaseCellModel.h"


//@interface UITableView (FDDIdentifierCell)
//
//- (FDDBaseTableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath cellClass:(Class)cellClass;
//
//@end

@implementation UITableView (FDDIdentifierCell)

- (FDDBaseTableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath cellClass:(Class)cellClass{
    if ([cellClass isSubclassOfClass:FDDBaseTableViewCell.class]) {
        NSString *identifier = [NSString stringWithFormat:@"%@ID", NSStringFromClass(cellClass)];
        FDDBaseTableViewCell *cell = [self dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            [self registerClass:cellClass forCellReuseIdentifier:identifier];
            cell = [self dequeueReusableCellWithIdentifier:identifier];
        }
        return cell;
    }
    return [FDDBaseTableViewCell new];
}

@end


@interface FDDTableViewConverter () 

@property (nonatomic, weak) FDDBaseViewController *tableViewController;

//key:selector     value:block
@property (nonatomic, strong) NSMutableDictionary *selectorBlocks;

@end

@implementation FDDTableViewConverter

- (instancetype)initWithTableViewController:(FDDBaseViewController *)tableViewController{
    self = [super init];
    if (self) {
        _tableViewController = tableViewController;
    }
    return self;
}

- (NSMutableDictionary *)selectorBlocks{
    if (!_selectorBlocks) {
        _selectorBlocks = [NSMutableDictionary dictionary];
    }
    return _selectorBlocks;
}

- (void)registerTableViewMethod:(SEL)selector handleResult:(resultBlock)block{
    [self.selectorBlocks setObject:block forKey:NSStringFromSelector(selector)];
}

- (id)seekResponseBlockWithFunction:(NSString *)func results:(NSArray *)results{
    if ([self.selectorBlocks.allKeys containsObject:func]) {
        resultBlock block = [self.selectorBlocks objectForKey:func];
        return block(results);
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tableViewController.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FDDBaseTableViewCell *backCell = [self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, indexPath]];
    if (backCell) {
        return backCell;
    }
    
    FDDBaseCellModel *cellModel = _tableViewController.dataArr[indexPath.row];
    FDDBaseTableViewCell *cell = [tableView cellForIndexPath:indexPath cellClass:cellModel.cellClass];
    [cell setCellData:cellModel.cellData delegate:self];
    [cell setSeperatorLine:indexPath numberOfRowsInSection:_tableViewController.dataArr.count];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat backHeight = [[self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, indexPath]] floatValue];
    if (backHeight > 0) {
        return backHeight;
    }
    FDDBaseCellModel *cellModel = _tableViewController.dataArr[indexPath.row];
    return cellModel.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, indexPath]];
}

@end
