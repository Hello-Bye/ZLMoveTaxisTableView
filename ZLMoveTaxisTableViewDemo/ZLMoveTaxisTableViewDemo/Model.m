//
//  SectionModel.m
//  ZLMoveTaxisTableViewDemo
//
//  Created by GeekZooStudio on 2017/5/24.
//  Copyright © 2017年 personal. All rights reserved.
//

#import "Model.h"
#import "NSObject+JSON.h"

@implementation RowModel

@end

@implementation SectionModel

+ (NSDictionary *)arrayContainModelClass {
    return @{@"rowModels" : @"RowModel"};
}

@end
