//
//  FDDTableViewConverter.h
//  FDDUITableViewDemoObjC
//
//  Created by denglibing on 2017/2/14.
//  Copyright © 2017年 denglibing. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FDDBaseViewController.h"

typedef id (^resultBlock)(NSArray *results);

@interface FDDTableViewConverter : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithTableViewController:(FDDBaseViewController *)tableViewController;

- (void)registerTableViewMethod:(SEL)selector handleResult:(resultBlock)block; 

@end
