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
- (NSMutableArray *)dataSourceInTableView:(ZLMoveTaxisTableView *)tableView;

@end

@protocol ZLMoveTaxisTableViewDelegate <UITableViewDelegate>

/// 当多组的时候，如果每一组不是一个NSMutableArray时（如：自定义组模型），需要代理手动交换数据源并移动cell, 并且需要返回交换之后的数据源
- (NSMutableArray *)tableView:(ZLMoveTaxisTableView *)tableview willChangeDataSource:(NSMutableArray *)dataSource source:(NSIndexPath *)source destination:(NSIndexPath *)destination;

/// 每次交换完数据源后都要通知代理
- (void)tableView:(ZLMoveTaxisTableView *)tableview didChangeDataSource:(NSMutableArray *)dataSource;
@end

@interface ZLMoveTaxisTableView : UITableView

@property (nonatomic, weak) id<ZLMoveTaxisTableViewDataSource> dataSource;
@property (nonatomic, weak) id<ZLMoveTaxisTableViewDelegate> delegate;
@end
