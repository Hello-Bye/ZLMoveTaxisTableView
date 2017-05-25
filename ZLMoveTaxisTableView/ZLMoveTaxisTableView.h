//
//  ZLMoveTaxisTableView.h
//  ZLMoveTaxisTableViewDemo
//
//  Created by GeekZooStudio on 2017/5/24.
//  Copyright © 2017年 personal. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZLMoveTaxisTableView;

@protocol ZLMoveTaxisTableViewDataSource <UITableViewDataSource>
@required
/// 返回数据源
- (NSArray *)dataSourceInTableView:(ZLMoveTaxisTableView *)tableView;

/// 交换后的数据源，需要保存新的数据源
- (void)tableView:(ZLMoveTaxisTableView *)tableView newDataSource:(NSArray *)newDataSource;
@end

@protocol ZLMoveTaxisTableViewDelegate <UITableViewDelegate>

@optional
/// 将要开始移动cell
- (void)tableView:(ZLMoveTaxisTableView *)tableView beginMoveCellAtIndexPath:(NSIndexPath *)indexPath;

/// 每次移动一次cell都会调用
- (void)tableView:(ZLMoveTaxisTableView *)tableView didMoveCellNewIndexPath:(NSIndexPath *)newIndexPath oldIndexPath:(NSIndexPath *)oldIndexPath;

/// 结束移动cell
- (void)tableView:(ZLMoveTaxisTableView *)tableview endMoveCellAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface ZLMoveTaxisTableView : UITableView

@property (nonatomic, weak) id<ZLMoveTaxisTableViewDataSource> dataSource;
@property (nonatomic, weak) id<ZLMoveTaxisTableViewDelegate> delegate;
@end
