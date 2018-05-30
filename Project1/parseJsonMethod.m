//
//  parseJsonMethod.m
//  Project1
//
//  Created by 黄洪彬 on 2018/5/30.
//  Copyright © 2018年 黄洪彬. All rights reserved.
//

#import "parseJsonMethod.h"
#import "NSDictionary.h"
@implementation ParseJsonMethod

@synthesize jsonString = _jsonString;
@synthesize jsonDictionary = _jsonDictionary;

-(void) initWithJsonFile:(char *)path
{
    //读入
    FILE *jsonFile = fopen(path, "r");
    char word[200];
    //初始化NSString
    _jsonString = [NSMutableString stringWithCapacity: 50];
    while (fgets(word, 200, jsonFile)) {
        //获取文本内容
//        word[strlen(word) - 1] = '\0';
        NSString *tmp = [NSString stringWithUTF8String: word];
        [_jsonString appendString: tmp];
    }
}


- (void) parseWithJsonString
{
    //将json数据解码
    NSData* jsonData;
    jsonData = [_jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        _jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                  options:NSJSONReadingMutableContainers
                                                               error: nil];
    }
}

- (void) parseWithJsonStringByMySelf
{
    
}
@end
