//
//  HDTableViewCell.m
//  FDDUITableViewDemoObjC
//
//  Created by denglibing on 2017/2/14.
//  Copyright © 2017年 denglibing. All rights reserved.
//

#import "HDTableViewCell.h"

@implementation HDTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.numberOfLines = 0;
        self.separateLineOffset = 10;
    }
    return self;
}

- (void)setCellData:(NSString *)fddCellData delegate:(id)delegate{
    self.fddCellData = fddCellData;
    self.fddDelegate = delegate;
    self.textLabel.text = fddCellData;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat height = [HDTableViewCell cellHeightWithCellData:self.fddCellData];
    self.textLabel.frame =  CGRectMake(10, 10, self.frame.size.width - 20, height - 20);
}

+ (CGFloat)cellHeightWithCellData:(NSString *)cellData{
    NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:14]};
    CGRect rect = [cellData boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, 999)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:dic
                                         context:nil];
    return 20 + rect.size.height;
}

@end
