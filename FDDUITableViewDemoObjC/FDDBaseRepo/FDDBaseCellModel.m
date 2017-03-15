//
//  FDDBaseCellModel.m
//  FDDUITableViewDemoObjC
//
//  Created by denglibing on 2017/2/14.
//  Copyright © 2017年 denglibing. All rights reserved.
//

#import "FDDBaseCellModel.h"

@implementation FDDBaseCellModel

+ (instancetype)modelFromCellClass:(Class)cellClass cellHeight:(CGFloat)cellHeight cellData:(id)cellData{
    FDDBaseCellModel *cellModel = [[self alloc] init];
    cellModel.cellClass = cellClass;
    cellModel.cellHeight = cellHeight;
    cellModel.cellData = cellData;
    return cellModel;
}

- (instancetype)initWithCellClass:(Class)cellClass cellHeight:(CGFloat)cellHeight cellData:(id)cellData{
    return [FDDBaseCellModel modelFromCellClass:cellClass cellHeight:cellHeight cellData:cellData];
}

@end
