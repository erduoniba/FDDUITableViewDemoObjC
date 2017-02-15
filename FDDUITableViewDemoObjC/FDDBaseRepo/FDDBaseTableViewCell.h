//
//  FDDBaseTableViewCell.h
//  FDDUITableViewDemoObjC
//
//  Created by denglibing on 2017/2/14.
//  Copyright © 2017年 denglibing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FDDBaseTableViewCell;

@protocol FDDBaseTableViewCellDelegate <NSObject>

- (void)fddTableViewCell:(FDDBaseTableViewCell *)cell anyObject:(id)obj;

@end

typedef NS_ENUM(NSInteger, FDDBaseTableViewCellType) {
    FDDBaseTableViewCellNone,       //上下线都隐藏
    FDDBaseTableViewCellAtFirst,    //下线隐藏,按照group样式即第一个cell,originx=0
    FDDBaseTableViewCellAtMiddle,   //下线隐藏,按照group样式即中间cell,originx=separateLineOffset
    FDDBaseTableViewCellAtLast,     //上下线都显示,按照group样式即最后一个cell,上线originx=separateLineOffset 下线originx=0
    FDDBaseTableViewCellNormal,     //下线隐藏,按照plain样式,originx=separateLineOffset
    FDDBaseTableViewCellSingle,     //上下线都显示，originx=0
};


@interface FDDBaseTableViewCell<ObjectType>: UITableViewCell

@property (nonatomic,weak) id<FDDBaseTableViewCellDelegate> fddDelegate;

/**
 *  分隔线的颜色值,默认为(208,208,208)
 */
@property (nonatomic,strong) UIColor *lineColor;

@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic,strong) ObjectType fddCellData;

/**
 *  分割线了偏移量,默认是0
 */
@property(nonatomic, assign) NSInteger separateLineOffset;

/**
 *  分隔线是上,还是下,还是中间的
 */
@property(nonatomic, assign) FDDBaseTableViewCellType cellType;

/**
 *  上横线
 */
@property (strong, nonatomic)  UIView *topLineView;

/**
 *  下横线,都是用来分隔cell的
 */
@property (strong, nonatomic)  UIView *bottomLineView;


+ (CGFloat)cellHeightWithCellData:(ObjectType)cellData;

+ (CGFloat)cellHeightWithCellData:(ObjectType)cellData boundWidth:(CGFloat)width;


- (void)setCellData:(id)fddCellData;

- (void)setCellData:(id)fddCellData delegate:(id)delegate;

- (void)setSeperatorLine:(NSIndexPath *)indexPath numberOfRowsInSection: (NSInteger)numberOfRowsInSection;

@end
