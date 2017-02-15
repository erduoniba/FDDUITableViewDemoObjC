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

- (void)dealloc{
    NSLog(@"%@ dealloc", NSStringFromClass(self.class));
}

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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger sections = [[self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView]] integerValue];
    if (sections > 0) {
        return sections;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = [[self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, @(section)]] integerValue];
    if (rows > 0) {
        return rows;
    }
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

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, @(section)]];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return [self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, @(section)]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, indexPath]] boolValue];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, indexPath]] boolValue];
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return [self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView]];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return [[self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, title, @(index)]] integerValue];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, @(editingStyle), indexPath]];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    [self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, sourceIndexPath, destinationIndexPath]];
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat backHeight = [[self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, indexPath]] floatValue];
    if (backHeight > 0) {
        return backHeight;
    }
    FDDBaseCellModel *cellModel = _tableViewController.dataArr[indexPath.row];
    return cellModel.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [[self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, @(section)]] floatValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return [[self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, @(section)]] floatValue];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, @(section)]];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, @(section)]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, indexPath]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self seekResponseBlockWithFunction:NSStringFromSelector(_cmd) results:@[tableView, indexPath]];
}

@end
