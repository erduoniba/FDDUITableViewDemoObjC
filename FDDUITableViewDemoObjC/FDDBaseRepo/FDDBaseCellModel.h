//
//  FDDBaseCellModel.h
//  FDDUITableViewDemoObjC
//
//  Created by denglibing on 2017/2/14.
//  Copyright © 2017年 denglibing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDDBaseTableViewCell.h"

@interface FDDBaseCellModel : NSObject

@property (nonatomic, strong) id cellData;                      //cell的数据源

//https://stackoverflow.com/questions/8592289/arc-the-meaning-of-unsafe-unretained
@property (nonatomic, assign) Class cellClass;                  //cell的Class
@property (nonatomic, weak)   id delegate;                      //cell的代理
@property (nonatomic, assign) CGFloat cellHeight;               //cell的高度，提前计算好
@property (nonatomic, strong) FDDBaseTableViewCell *staticCell; //兼容静态的cell

+ (instancetype)modelFromCellClass:(Class)cellClass cellHeight:(CGFloat)cellHeight cellData:(id)cellData;
- (instancetype)initWithCellClass:(Class)cellClass cellHeight:(CGFloat)cellHeight cellData:(id)cellData;

@end
