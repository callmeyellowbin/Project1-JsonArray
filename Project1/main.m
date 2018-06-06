//
//  main.m
//  Project1
//
//  Created by 黄洪彬 on 2018/5/30.
//  Copyright © 2018年 黄洪彬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "parseJsonMethod.h"
#import "NSDictionary.h"
#import "NSMutableArray.h"
int main(int argc, char * argv[]) {
    @autoreleasepool {
        //TODO:判断key内带引号、负号，以及多余的引号等
        ParseJsonMethod *method = [[ParseJsonMethod alloc] init];
        char* path = "/Users/huanghongbin/Downloads/data/error_16.txt";
        //获取文本内容
        NSString *jsonStr = [[NSString alloc] init];
        jsonStr = [method getStringWithJsonFile: path];
        [method parseWithJsonString];
        //解析JSON数据
        id jsonResult = nil;
        jsonResult = [ParseJsonMethod JsonObjectWithString: jsonStr];
        NSLog(@"result is: %@", [method jsonDictionaryRsult]);
        //jsonResult即为所求内容
        if ([jsonResult isKindOfClass: [NSMutableArray class]]) {
            NSLog(@"It's an array:\n%@", [jsonResult my_description]);
        }
        else if ([jsonResult isKindOfClass: [NSMutableDictionary class]]) {
            NSLog(@"It's an dictionary:\n%@", [jsonResult my_description]);
        }
        else {
            //不合法
            NSLog(@"%@", jsonResult);
        }
        if ([[method jsonDictionaryRsult] isEqual: jsonResult])
            NSLog(@"YES!");
        else
            NSLog(@"NO!");
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
