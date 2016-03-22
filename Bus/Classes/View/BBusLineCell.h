//
//  BBusLineCell.h
//  Bus
//
//  Created by 朱辉 on 16/3/20.
//  Copyright © 2016年 朱辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBusLineViewModel;

@interface BBusLineCell : UITableViewCell

+ (instancetype)busLineCellWithTableView:(UITableView*)tableView;

/**
 *  公交线路名称
 */
@property (nonatomic,copy) NSString* fullName;

/**
 *  viewmodel
 */
@property (nonatomic,strong) BBusLineViewModel* viewModel;

@end
