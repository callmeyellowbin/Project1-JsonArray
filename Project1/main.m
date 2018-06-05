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
        char* path = "/Users/huanghongbin/Library/Mobile Documents/com~apple~TextEdit/Documents/jsonFile.txt";
        
        ParseJsonMethod *method = [[ParseJsonMethod alloc] init];
        //获取文本内容
        [method initWithJsonFile: path];
        //解析JSON数据
//        [method parseWithJsonString];
        
        //输出获得的字典。
        //输出时中文转码错误，只能通过类别定义来返回NSString从而输出
        if ([method parseWithJsonStringByMySelf])
            NSLog(@"The result dictionary is %@", [[method jsonArray] my_description]);
        else
            NSLog(@"JSON数据不合法！");
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
