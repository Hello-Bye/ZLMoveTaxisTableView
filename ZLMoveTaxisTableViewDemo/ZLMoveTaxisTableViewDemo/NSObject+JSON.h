//
//  NSObject+JSON.h
//  ZLMoveTaxisTableViewDemo
//
//  Created by GeekZooStudio on 2017/5/26.
//  Copyright © 2017年 personal. All rights reserved.
//
//
//  利用runtime简单实现json转model

#import <Foundation/Foundation.h>

@protocol arrayContainModelDelegate <NSObject>

@optional
/// 如果一个model的一个元素是数组类型，需要该model实现此协议方法，返回数组元素指定的类型
/// 例如：NSArray<class *> *array, 需要返回@{@"array" : @"class"}
+ (nonnull NSDictionary *)arrayContainModelClass;
@end

@interface NSObject (JSON) <arrayContainModelDelegate>

+ (nonnull instancetype)modelWithJSON:(nonnull NSDictionary *)json;

@end
