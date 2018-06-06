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
        
        ParseJsonMethod *method = [[ParseJsonMethod alloc] init];
        char* path = "/Users/huanghongbin/Library/Mobile Documents/com~apple~TextEdit/Documents/jsonFile.txt";
        //获取文本内容
        NSString *jsonStr = [[NSString alloc] init];
        jsonStr = [method getStringWithJsonFile: path];

        id jsonResult = nil;
        jsonResult = [ParseJsonMethod JsonObjectWithString: jsonStr];
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
        //解析JSON数据
//        [method parseWithJsonString];
        
        //输出获得的字典。
        //输出时中文转码错误，只能通过类别定义来返回NSString从而输出
        
        
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
