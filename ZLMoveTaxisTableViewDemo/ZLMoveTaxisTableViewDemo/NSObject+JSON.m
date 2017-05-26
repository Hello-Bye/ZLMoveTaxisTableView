//
//  NSObject+JSON.m
//  ZLMoveTaxisTableViewDemo
//
//  Created by GeekZooStudio on 2017/5/26.
//  Copyright © 2017年 personal. All rights reserved.
//

#import "NSObject+JSON.h"
#import <objc/runtime.h>

@implementation NSObject (JSON)

+ (nonnull instancetype)modelWithJSON:(nonnull NSDictionary *)json {
    // 如果json为空或者不是NSDictionary 就抛出一个错误
    NSAssert((json && [json isKindOfClass:[NSDictionary class]]), @"json to model is can not empty");
    
    id model = [[self alloc] init];
    
    // runtime
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(self, &outCount);
    
    for (int i = 0; i < outCount; i++) {
        // 根据角标，从数组取出对应的成员属性
        Ivar ivar = ivars[i];
        
        // 获取成员属性名
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 处理成员属性名->字典中的key
        // 从第一个角标开始截取
        NSString *key = [name substringFromIndex:1];
        
        // 根据成员属性名去字典中查找对应的value
        id value = json[key];
        
        // 二级转换:如果字典中还有字典，也需要把对应的字典转换成模型
        // 判断下value是否是字典
        if ([value isKindOfClass:[NSDictionary class]]) {
            // 字典转模型
            // 获取模型的类对象，调用modelWithDict
            // 模型的类名已知，就是成员属性的类型
            
            // 获取成员属性类型
            NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
            // 生成的是这种@"@\"User\"" 类型 -》 @"User"  在OC字符串中 \" -> "，\是转义的意思，不占用字符
            // 裁剪类型字符串
            NSRange range = [type rangeOfString:@"\""];
            
            type = [type substringFromIndex:range.location + range.length];
            
            range = [type rangeOfString:@"\""];
            
            // 裁剪到哪个角标，不包括当前角标
            type = [type substringToIndex:range.location];
            
            // 根据字符串类名生成类对象
            Class modelClass = NSClassFromString(type);
            
            if (modelClass) { // 有对应的模型才需要转
                // 把字典转模型
                value = [modelClass modelWithJSON:value];
            }
        }
        
        // 三级转换：NSArray中也是字典，把数组中的字典转换成模型.
        // 判断值是否是数组
        if ([value isKindOfClass:[NSArray class]]) {
            // 判断对应类有没有实现字典数组转模型数组的协议
            if ([self respondsToSelector:@selector(arrayContainModelClass)]) {
                
                // 转换成id类型，就能调用任何对象的方法
                id idSelf = self;
                
                // 获取数组中字典对应的模型
                NSString *type = [idSelf arrayContainModelClass][key];
                
                // 生成模型
                Class classModel = NSClassFromString(type);
                NSMutableArray *arrM = [NSMutableArray array];
                // 遍历字典数组，生成模型数组
                for (NSDictionary *dict in value) {
                    // 字典转模型
                    id model =  [classModel modelWithJSON:dict];
                    [arrM addObject:model];
                }
                
                // 把模型数组赋值给value
                value = arrM;
            }
        }
        
        if (value) { // 有值，才需要给模型的属性赋值
            // 利用KVC给模型中的属性赋值
            [model setValue:value forKey:key];
        }
    }
    
    return model;
}

@end
