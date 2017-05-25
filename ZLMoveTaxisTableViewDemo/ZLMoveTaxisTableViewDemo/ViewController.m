//
//  ViewController.m
//  ZLMoveTaxisTableViewDemo
//
//  Created by GeekZooStudio on 2017/5/24.
//  Copyright © 2017年 personal. All rights reserved.
//

#import "ViewController.h"
#import "ZLMoveTaxisTableView.h"
#import "Model.h"

@interface ViewController () <ZLMoveTaxisTableViewDataSource, ZLMoveTaxisTableViewDelegate>
@property (weak, nonatomic) IBOutlet ZLMoveTaxisTableView *tableview;

@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.tableview.rowHeight = 80;
    self.tableview.tableFooterView = [UIView new];
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        // 模拟假数据
        for (NSInteger i = 0; i < 3; i++) {
            NSMutableArray *sectionM = [NSMutableArray array];
            [_dataSource addObject:sectionM];
            
            for (NSInteger j = 0; j < 3; j++) {
                RowModel *row = [[RowModel alloc] init];
                row.rowTitle = [NSString stringWithFormat:@"%ld-%ld", i, j];
                [sectionM addObject:row];
            }
        }
    }
    return _dataSource;
}

#pragma mark - ZLMoveTaxisTableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *sectionM = self.dataSource[section];
    return sectionM.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLMoveTaxisTableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZLMoveTaxisTableViewCell"];
    }
    
    NSMutableArray *sectionM = self.dataSource[indexPath.section];
    RowModel *model = sectionM[indexPath.row];
    cell.textLabel.text = model.rowTitle;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @(section).stringValue;
}

- (NSMutableArray *)dataSourceInTableView:(UITableView *)tableView {
    return self.dataSource;
}

- (void)tableView:(ZLMoveTaxisTableView *)tableView newDataSource:(NSArray *)newDataSource {
    self.dataSource = newDataSource.mutableCopy;
}

#pragma mark - ZLMoveTaxisTableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
