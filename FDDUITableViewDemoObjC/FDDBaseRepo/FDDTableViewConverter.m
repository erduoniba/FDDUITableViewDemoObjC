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

- (void)registerTableViewMethod:(SEL)selector handleParams:(resultBlock)block{
    [self.selectorBlocks setObject:block forKey:NSStringFromSelector(selector)];
}

- (id)invocationWithSelector:(SEL)selector params:(NSArray *)params{
    NSMethodSignature *sinature = [_tableViewController methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sinature];
    invocation.target = _tableViewController;
    invocation.selector = selector;
    for (int i=0; i<params.count; i++) {
        id param = params[i];
        //atIndex的下标必须从2开始。原因为：0 1 两个参数已经被target 和selector占用
        [invocation setArgument:&param atIndex:i+2];
    }
    //retain 所有参数，防止参数被释放dealloc
    [invocation retainArguments];
    
    //消息调用
    [invocation invoke];
    
    //获得返回值类型
    const char *returnType = sinature.methodReturnType;
    //声明返回值变量
    id returnValue;
    
    if( !strcmp(returnType, @encode(void)) ){
        //如果没有返回值，也就是消息声明为void，那么returnValue=nil
        returnValue =  nil;
    }
    else if( !strcmp(returnType, @encode(id)) ){
        [invocation getReturnValue:&returnValue];
    }
    else {
        //如果返回值为普通类型NSInteger、BOOL、CGFloat
        //返回值长度
        NSUInteger length = [sinature methodReturnLength];
        
        //根据长度申请内存
        void *buffer = (void *)malloc(length);
        
        //为变量赋值
        [invocation getReturnValue:buffer];
        
        if( !strcmp(returnType, @encode(BOOL)) ) {
            returnValue = [NSNumber numberWithBool:*((BOOL*)buffer)];
        }
        else if( !strcmp(returnType, @encode(NSInteger)) ){
            returnValue = [NSNumber numberWithInteger:*((NSInteger*)buffer)];
        }
        else if ( !strcmp(returnType, @encode(CGFloat)) ) {
            returnValue = [NSNumber numberWithFloat:*((NSInteger*)buffer)];
        }
    }
    
    return returnValue;
}

- (id)converterFunction:(NSString *)func params:(NSArray *)params{
    if (_converterType == FDDTableViewConverter_Response) {
        SEL selector = NSSelectorFromString(func);
        if ([_tableViewController respondsToSelector:selector]) {
            return [self invocationWithSelector:selector params:params];
        }
        
        return nil;
    }
    
    if ([self.selectorBlocks.allKeys containsObject:func]) {
        resultBlock block = [self.selectorBlocks objectForKey:func];
        return block(params);
    }
    return nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger sections = [[self converterFunction:NSStringFromSelector(_cmd) params:@[tableView]] integerValue];
    if (sections > 0) {
        return sections;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = [[self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, @(section)]] integerValue];
    if (rows > 0) {
        return rows;
    }
    return _tableViewController.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FDDBaseTableViewCell *backCell = [self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, indexPath]];
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
    return [self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, @(section)]];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return [self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, @(section)]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, indexPath]] boolValue];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, indexPath]] boolValue];
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return [self converterFunction:NSStringFromSelector(_cmd) params:@[tableView]];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return [[self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, title, @(index)]] integerValue];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, @(editingStyle), indexPath]];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    [self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, sourceIndexPath, destinationIndexPath]];
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat backHeight = [[self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, indexPath]] floatValue];
    if (backHeight > 0) {
        return backHeight;
    }
    FDDBaseCellModel *cellModel = _tableViewController.dataArr[indexPath.row];
    return cellModel.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [[self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, @(section)]] floatValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return [[self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, @(section)]] floatValue];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, @(section)]];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, @(section)]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, indexPath]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self converterFunction:NSStringFromSelector(_cmd) params:@[tableView, indexPath]];
}

@end
