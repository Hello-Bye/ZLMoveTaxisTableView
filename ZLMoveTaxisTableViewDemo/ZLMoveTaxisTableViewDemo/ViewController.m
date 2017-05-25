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

@property (nonatomic, strong) NSMutableArray<SectionModel *> *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.tableview.rowHeight = 50;
}

- (NSMutableArray<SectionModel *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        // 模拟假数据，5组
        for (NSInteger i = 0; i < 5; i++) {
            SectionModel *section = [[SectionModel alloc] init];
            section.sectionTitle = @(i).stringValue;
            section.rowModels = [NSMutableArray array];
            [_dataSource addObject:section];
            
            // 5行
            for (NSInteger j = 0; j < 5; j++) {
                RowModel *row = [[RowModel alloc] init];
                row.rowTitle = @(j).stringValue;
                [section.rowModels addObject:row];
            }
        }
    }
    return _dataSource;
}

#pragma mark - ZLMoveTaxisTableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
//    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SectionModel *sectionModel = self.dataSource[section];
    return sectionModel.rowModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLMoveTaxisTableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZLMoveTaxisTableViewCell"];
    }
    
    SectionModel *sectionModel = self.dataSource[indexPath.section];
    RowModel *rowModel = sectionModel.rowModels[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@", sectionModel.sectionTitle, rowModel.rowTitle];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    SectionModel *sectionModel = self.dataSource[section];
    return sectionModel.sectionTitle;
}

- (NSMutableArray *)dataSourceInTableView:(UITableView *)tableView {
    return self.dataSource;
}

#pragma mark - ZLMoveTaxisTableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSMutableArray *)tableView:(ZLMoveTaxisTableView *)tableview willChangeDataSource:(NSMutableArray *)dataSource source:(NSIndexPath *)source destination:(NSIndexPath *)destination {
    
    SectionModel *sourceSectionM = dataSource[source.section];
    SectionModel *destSectionM = dataSource[destination.section];
    
    RowModel *sourceRow = sourceSectionM.rowModels[source.row];
//    RowModel *destRow = destSectionM.rowModels[destination.row];
    
    [destSectionM.rowModels insertObject:sourceRow atIndex:destination.row];
//    [sourceSectionM.rowModels insertObject:destRow atIndex:source.row];
    
    [sourceSectionM.rowModels removeObjectAtIndex:source.row];
//    [destSectionM.rowModels removeObjectAtIndex:destination.row];
    
    [self.tableview beginUpdates];
    [tableview moveRowAtIndexPath:source toIndexPath:destination];
//    [tableview moveRowAtIndexPath:destination toIndexPath:source];
    [self.tableview endUpdates];
    
    return dataSource;
}

- (void)tableView:(ZLMoveTaxisTableView *)tableview didChangeDataSource:(NSMutableArray *)dataSource {
    self.dataSource = dataSource;
}

@end
