//
//  SectionModel.h
//  ZLMoveTaxisTableViewDemo
//
//  Created by GeekZooStudio on 2017/5/24.
//  Copyright © 2017年 personal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RowModel : NSObject
@property (nonatomic, copy) NSString *rowTitle;
@end

@interface SectionModel : NSObject
@property (nonatomic, copy) NSString *sectionTitle;
@property (nonatomic, strong) NSMutableArray<RowModel *> *rowModels;
@end
